require 'spike/associations/association'
require 'spike/associations/has_many'
require 'spike/associations/has_one'
require 'spike/associations/belongs_to'

module Spike
  module Associations
    extend ActiveSupport::Concern

    included do
      class_attribute :associations
      self.associations = {}
    end

    module ClassMethods

      def has_many(name, options = {})
        associations[name] = options.merge(type: HasMany)
      end

      def has_one(name, options = {})
        associations[name] = options.merge(type: HasOne)
      end

      def belongs_to(name, options = {})
        associations[name] = options.merge(type: BelongsTo)
      end
    end

    private

      def has_association?(name)
        associations.has_key?(name)
      end

      def get_association(name)
        options = associations[name]
        options[:type].activate self, name, options
      end

  end
end
