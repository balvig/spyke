require 'spike/association'

module Spike
  module Associations
    extend ActiveSupport::Concern

    included do
      class_attribute :associations
      self.associations = []

      class << self
        alias :has_one :has_many
        alias :belongs_to :has_many
      end
    end

    module ClassMethods
      def has_many(association)
        associations << association
      end
    end

    private

      def has_association?(name)
        associations.include?(name)
      end

      def get_association(name)
        Association.new(self, name)
      end

  end
end
