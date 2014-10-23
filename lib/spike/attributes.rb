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
      assign_attributes(attributes)
      @uri_template = current_scope.uri_template
    end

    def assign_attributes(attributes)
      self.attributes = Attribute.paramify(attributes)
    end

    def attributes=(new_attributes)
      @attributes = default_attributes.merge(current_scope.params).with_indifferent_access
      use_setters(new_attributes) if new_attributes
      @attributes
    end

    def ==(other)
      other.is_a?(Spike::Base) && id == other.id
    end

    private

      def default_attributes
        self.class.default_attributes
      end

      def use_setters(attributes)
        attributes.each do |key, value|
          send "#{key}=", value
        end
      end

      def method_missing(name, *args, &block)
        case
        when has_association?(name) then get_association(name)
        when has_attribute?(name)   then get_attribute(name)
        when predicate?(name)       then get_predicate(name)
        when setter?(name)          then set_attribute(name, args.first)
        else super
        end
      end

      def respond_to_missing?(name, include_private = false)
        has_association?(name) || has_attribute?(name) || predicate?(name) || super
      end

      def has_attribute?(name)
        attributes.has_key?(name)
      end

      def get_attribute(name)
        attributes[name]
      end

      def predicate?(name)
        name.to_s.end_with?('?')
      end

      def get_predicate(name)
        !!get_attribute(depredicate(name))
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
