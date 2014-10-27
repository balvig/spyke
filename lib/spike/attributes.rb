require 'spike/collection'

module Spike
  module Attributes
    extend ActiveSupport::Concern

    included do
      attr_reader :attributes
    end

    module ClassMethods
      def attributes(*args)
        args.each do |attr|
          define_method attr do
            attribute(attr)
          end
        end
      end
    end

    def initialize(attributes = {})
      self.attributes = attributes
      @uri_template = current_scope.uri_template
    end

    def attributes=(new_attributes)
      @attributes ||= current_scope.params.with_indifferent_access
      use_setters parse(new_attributes) if new_attributes
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

    def inspect
      "#<#{self.class}(#{uri}) id: #{id.inspect} #{inspect_attributes}>"
    end

    private

      def default_attributes
        self.class.default_attributes
      end

      def parse(attributes)
        attributes.each_with_object({}) do |(key, value), parameters|
          parameters[key] = parse_value(value)
        end
      end

      def parse_value(value)
        case
        when value.is_a?(Spike::Base)         then parse(value.attributes)
        when value.is_a?(Hash)                then parse(value)
        when value.is_a?(Array)               then value.map { |v| parse_value(v) }
        when value.respond_to?(:content_type) then Faraday::UploadIO.new(value.path, value.content_type)
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
        when association?(name) then association(name).run
        when attribute?(name)   then attribute(name)
        when predicate?(name)   then predicate(name)
        when setter?(name)      then set_attribute(name, args.first)
        else super
        end
      end

      def respond_to_missing?(name, include_private = false)
        association?(name) || attribute?(name) || predicate?(name) || super
      end

      def association?(name)
        associations.has_key?(name)
      end

      def association(name)
        options = associations[name]
        options[:type].new(self, name, options)
      end

      def attribute?(name)
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

      def inspect_attributes
        attributes.except(:id).map { |k, v| "#{k}: #{v.inspect}" }.join(' ')
      end
  end
end
