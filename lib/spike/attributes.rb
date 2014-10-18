module Spike
  module Attributes
    extend ActiveSupport::Concern

    included do
      attr_accessor :attributes
    end

    def initialize(attributes = {})
      self.attributes = attributes.with_indifferent_access
    end

    private

      def method_missing(name, *args, &block)
        if has_association?(name)
          get_association(name)
        elsif has_attribute?(name)
          get_attribute(name)
        elsif predicate?(name)
          get_predicate(name)
        elsif setter?(name)
          set_attribute(name, args.first)
        else
          super
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
