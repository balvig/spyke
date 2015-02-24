require 'spyke/relation'
require 'spyke/result'

module Spyke
  module Associations
    class Association < Relation
      attr_reader :parent, :name

      def initialize(klass, parent, name, options = {})
        super(klass, options)
        @parent, @name = parent, name
      end

      def load
        find_one # Override for plural associations that return an association object
      end

      def assign_nested_attributes(attributes)
        update_parent new(attributes)
      end

      def create(attributes = {})
        add_to_parent super
      end

      def new(*args)
        add_to_parent super
      end

      alias :build :new

      private

        def add_to_parent(record)
          update_parent record
        end

        def foreign_key
          (@options[:foreign_key] || "#{parent.class.model_name.param_key}_id").to_sym
        end

        def fetch
          fetch_embedded || super
        end

        def fetch_embedded
          if embedded
            Result.new(data: embedded)
          elsif !uri
            Result.new(data: nil)
          end
        end

        def embedded
          parent.attributes[name]
        end

        def update_parent(value)
          parent.attributes[name] = value
        end
    end
  end
end
