module Spike
  module Attributes
    extend ActiveSupport::Concern

    included do
      attr_accessor :attributes
    end

    def initialize(attributes = {})
      self.attributes = attributes
    end

    def persisted?
      id?
    end

    private

      def has_attribute?(name)
        attributes.keys.include?(name)
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

  end
end
