require 'spike/associations/association'
require 'spike/associations/has_many'
require 'spike/associations/has_one'
require 'spike/associations/belongs_to'

module Spike
  module Associations
    extend ActiveSupport::Concern

    included do
      class_attribute :associations
      self.associations = {}.freeze
    end

    module ClassMethods

      def has_many(name, options = {})
        self.associations = associations.merge(name => options.merge(type: HasMany))
      end

      def has_one(name, options = {})
        self.associations = associations.merge(name => options.merge(type: HasOne))
      end

      def belongs_to(name, options = {})
        self.associations = associations.merge(name => options.merge(type: BelongsTo))
      end

      def accepts_nested_attributes_for(*names)
        names.each do |association_name|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{association_name}_attributes=(association_attributes)
              build_association(:#{association_name}).assign_nested_attributes(association_attributes)
              #attributes[:#{association_name}] = association_attributes
              #self.#{association_name}.assign_nested_attributes(attributes)
            end
          RUBY
        end
      end
    end

    private

      def has_association?(name)
        associations.has_key?(name)
      end

      def get_association(name)
        build_association(name).activate
      end

      def build_association(name)
        options = associations[name]
        options[:type].new(self, name, options)
      end

  end
end
