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

        define_method "#{name.to_s.singularize}_ids=" do |ids|
          ids.each { |id| association(name).build(id: id) }
        end

        define_method "#{name.to_s.singularize}_ids" do
          association(name).map(&:id)
        end
      end

      def has_one(name, options = {})
        self.associations = associations.merge(name => options.merge(type: HasOne))
        define_method "build_#{name}" do |attributes = nil|
          association(name).build(attributes)
        end
      end

      def belongs_to(name, options = {})
        self.associations = associations.merge(name => options.merge(type: BelongsTo))
      end

      def accepts_nested_attributes_for(*names)
        names.each do |association_name|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{association_name}_attributes=(association_attributes)
              association(:#{association_name}).assign_nested_attributes(association_attributes)
            end
          RUBY
        end
      end
    end
  end
end
