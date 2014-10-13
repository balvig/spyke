require 'spike/association'

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
      def has_many(name)
        associations[name] = :collection
      end

      def belongs_to(name)
        associations[name] = :singular
      end
    end

    private

      def has_association?(name)
        associations.keys.include?(name)
      end

      def get_association(name)
        assoc = Association.new(self, name)
        assoc = assoc.find_one unless associations[name] == :collection
        assoc
      end

  end
end
