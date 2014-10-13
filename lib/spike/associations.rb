module Spike
  module Associations
    extend ActiveSupport::Concern

    included do
      class_attribute :associations
      self.associations = []
    end

    module ClassMethods
      def has_many(association)
        self.associations += [association]
      end

      def has_one(association)
        has_many(association)
      end
    end

    private

      def has_association?(name)
        associations.include?(name)
      end

      def build_association(name)
        klass = name.to_s.classify.constantize
        data = attributes[name]
        return klass.new(data) unless data.is_a?(Array)
        data.map do |attr|
          klass.new(attr)
        end
      end

  end
end
