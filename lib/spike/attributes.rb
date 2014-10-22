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
        new result.data if result.data.present?
      end

      def new_collection_from_result(result)
        Collection.new result.data.map { |record| new(record) }, result.metadata
      end

    end

    def initialize(attributes = {})
      self.attributes = parse(attributes).with_indifferent_access
      @uri_template = current_scope.uri_template
    end

    def attributes=(attributes)
      @attributes = default_attributes.merge(current_scope.params).merge(attributes)
    end

    def ==(other)
      attributes == other.attributes
    end

    private

      def current_scope
        self.class.current_scope
      end

      def default_attributes
        self.class.default_attributes
      end

      def parse(input)
        if input.respond_to?(:attributes)
          input.attributes
        else
          input
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
