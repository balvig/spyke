require 'spike/relation'
require 'spike/result'
require 'spike/attribute'

module Spike
  module Associations
    class Association < Relation

      attr_reader :parent, :name

      def initialize(parent, name, options = {})
        super (options[:class_name] || name.to_s).classify.constantize
        @parent, @name, @options = parent, name, options
      end

      def activate
        find_one # Override for plural associations that return an association object
      end

      def assign_nested_attributes(attributes)
        parent.attributes[name] = new(attributes).attributes
      end

      private

        def foreign_key
          (@options[:foreign_key] || "#{parent.class.model_name.param_key}_id").to_sym
        end

        def fetch
          fetch_embedded || super
        end

        def fetch_embedded
          Result.new(data: embedded_attributes) if embedded_attributes
        end

        def embedded_attributes
          parent.attributes[name]
        end

    end
  end
end
