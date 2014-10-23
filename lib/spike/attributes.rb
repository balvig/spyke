require 'spike/collection'

module Spike
  module Attributes
    extend ActiveSupport::Concern

    included do
      attr_reader :attributes
    end

    module ClassMethods
      def attributes(*args)
        @attributes ||= args
      end

      def default_attributes
        HashWithIndifferentAccess[Array(@attributes).map {|a| [a, nil]}]
      end

      def new_or_collection_from_result(result)
        if result.data.is_a?(Array)
          new_collection_from_result(result)
        else
          new_from_result(result)
        end
      end

      def new_from_result(result)
        new result.data if result.data
      end

      def new_collection_from_result(result)
        Collection.new Array(result.data).map { |record| new(record) }, result.metadata
      end
    end

    def initialize(attributes = {})
      self.attributes = attributes
      @uri_template = current_scope.uri_template
    end

    def attributes=(new_attributes)
      @attributes ||= default_attributes.merge(current_scope.params)
      use_setters process(new_attributes) if new_attributes
    end

    def id
      attributes[:id]
    end

    def id=(value)
      attributes[:id] = value if value.present?
    end


    def ==(other)
      other.is_a?(Spike::Base) && id == other.id
    end

    private

      def default_attributes
        self.class.default_attributes
      end

      def process(attributes)
        attributes.each_with_object({}) do |(key, value), parameters|
          parameters[key] = process_value(value)
        end
      end

      def process_value(value)
        case
        when value.is_a?(Spike::Base)         then process(value.attributes)
        when value.respond_to?(:content_type) then Faraday::UploadIO.new(value.path, value.content_type)
        when value.is_a?(Hash)                then process(value)
        when value.is_a?(Array)               then value.map { |v| process_value(v) }
        else value
        end
      end

      def use_setters(attributes)
        attributes.each do |key, value|
          send "#{key}=", value
        end
      end

      def method_missing(name, *args, &block)
        case
        when has_association?(name) then association(name).run
        when has_attribute?(name)   then attribute(name)
        when predicate?(name)       then predicate(name)
        when setter?(name)          then set_attribute(name, args.first)
        else super
        end
      end

      def respond_to_missing?(name, include_private = false)
        has_association?(name) || has_attribute?(name) || predicate?(name) || super
      end

      def has_association?(name)
        associations.has_key?(name)
      end

      def association(name)
        options = associations[name]
        options[:type].new(self, name, options)
      end

      def has_attribute?(name)
        attributes.has_key?(name)
      end

      def attribute(name)
        attributes[name]
      end

      def predicate?(name)
        name.to_s.end_with?('?')
      end

      def predicate(name)
        !!attribute(depredicate(name))
      end

      def depredicate(name)
        name.to_s.chomp('?').to_sym
      end

      def setter?(name)
        name.to_s.end_with?('=')
      end

      def set_attribute(name, value)
        attributes[name.to_s.chomp('=')] = value
      end

  end
end
