require 'spike/associations/association'
require 'spike/path'

module Spike
  module Associations
    class HasMany < Association

      def initialize(*args)
        super
        @options[:uri_template] ||= "/#{parent.class.model_name.plural}/:#{foreign_key}/#{klass.model_name.plural}/:id"
        @params[foreign_key] = parent.id
      end

      def run
        self
      end

      def assign_nested_attributes(collection)
        #TODO: Clean this up!!1
        collection = collection.values if collection.is_a?(Hash)

        collection.each do |attributes|
          existing = Array(parent.attributes[name]).index { |r| r[:id] && r[:id].to_s == attributes.with_indifferent_access[:id].to_s }
          if existing
            existing_attributes = parent.attributes[name][existing]
            parent.attributes[name][existing] = existing_attributes.merge(attributes)
          else
            build(attributes)
          end
        end
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
