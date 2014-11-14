require 'spike/relation'
require 'spike/result'

module Spike
  module Associations
    class Association < Relation
      attr_reader :parent, :name

      def initialize(parent, name, options = {})
        super (options[:class_name] || name.to_s).classify.constantize, options
        @parent, @name = parent, name
      end

      def load
        find_one # Override for plural associations that return an association object
      end

      def assign_nested_attributes(attributes)
        parent.attributes[name] = new(attributes).attributes
      end

      def create(attributes = {})
        add_to_parent super
      end

      def new(*args)
        add_to_parent super
      end

      def build(*args)
        new(*args)
      end

      private

        def add_to_parent(record)
          parent.attributes[name] = record.attributes
          record
        end

        def foreign_key
          (@options[:foreign_key] || "#{parent.class.model_name.param_key}_id").to_sym
        end

        def fetch
          fetch_embedded || super
        end

        def fetch_embedded
          if embedded_attributes
            Result.new(data: embedded_attributes)
          elsif !uri_template
            Result.new(data: nil)
          end
        end

        def embedded_attributes
          parent.attributes[name]
        end
    end
  end
end
