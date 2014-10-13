module Spike
  module Attributes
    extend ActiveSupport::Concern

    included do
      attr_accessor :attributes
    end

    def initialize(attributes)
      self.attributes = attributes
    end

    private

      def has_attribute?(name)
        attributes.keys.include?(name)
      end

      def build_attribute(name)
        attributes[name]
      end

      def predicate?(name)
        name.to_s.end_with?('?')
      end

      def depredicate(name)
        name.to_s.chomp('?').to_sym
      end

      def build_predicate(name)
        !!build_attribute(depredicate(name))
      end

  end
end
