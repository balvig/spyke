module Spyke
  module Associations
    class HasMany < Association
      def initialize(*args)
        super
        @options.reverse_merge!(uri: "/#{parent.class.model_name.plural}/:#{foreign_key}/#{klass.model_name.plural}/:id")
        @params[foreign_key] = parent.id
      end

      def load
        self
      end

      def assign_nested_attributes(collection)
        collection = collection.values if collection.is_a?(Hash)
        replace_existing! unless primary_keys_present?

        collection.each do |attributes|
          if existing = find_existing_attributes(attributes.with_indifferent_access[:id])
            existing.merge!(attributes)
          else
            build(attributes)
          end
        end
      end

      private

        def find_existing_attributes(id)
          embedded_attributes.to_a.find { |attr| attr[:id] && attr[:id].to_s == id.to_s }
        end

        def primary_keys_present?
          embedded_attributes && embedded_attributes.any? { |attr| attr.has_key?(:id) }
        end

        def replace_existing!
          parent.attributes[name] = []
        end

        def add_to_parent(record)
          parent.attributes[name] ||= []
          parent.attributes[name] << record.attributes
          record
        end
    end
  end
end
