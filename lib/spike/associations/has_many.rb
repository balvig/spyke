require 'spike/associations/association'
require 'spike/path'

module Spike
  module Associations
    class HasMany < Association

      def initialize(*args)
        super
        @options[:uri_template] ||= File.join parent.class.model_name.plural, ":#{foreign_key}", klass.model_name.plural, ':id'
        @params[foreign_key] = parent.try(:id)
      end

      def activate
        self
      end

      def assign_nested_attributes(collection)
        collection = collection.values if collection.is_a?(Hash)
        collection.each do |attributes|
          build(attributes)
        end
      end

      def build(*args)
        add_to_parent super
      end

      private

        def add_to_parent(record)
          parent.attributes[name] ||= []
          parent.attributes[name] << record.attributes
          record
        end

    end
  end
end
