module Spike
  module Attributes
    extend ActiveSupport::Concern

    included do
      attr_accessor :attributes
    end

    def initialize(attributes)
      self.attributes = attributes.deep_symbolize_keys
    end

    private

      def has_attribute?(name)
        attributes.keys.include?(name)
      end

      def build_attribute(name)
        attributes[name]
      end

  end
end
