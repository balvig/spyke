require 'spike/association_proxy'

module Spike
  module Associations
    extend ActiveSupport::Concern

    included do
      class_attribute :associations
      self.associations = {}

      class << self
        alias :has_one :belongs_to
      end
    end

    module ClassMethods
      def has_many(name, **options)
        options.reverse_merge!(type: :collection, name: name)
        associations[name] = options
      end

      def belongs_to(name, **options)
        options.reverse_merge!(type: :singular)
        has_many(name, options)
      end
    end

    private

      def has_association?(name)
        associations.keys.include?(name)
      end

      def get_association(name)
        association = associations[name]
        proxy = AssociationProxy.new(self, association)
        proxy = proxy.find_one unless association[:type] == :collection
        proxy
      end

  end
end
