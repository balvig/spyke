require 'spike/relation'

module Spike
  module Scopes
    extend ActiveSupport::Concern

    included do
      class_attribute :current_scope
      self.current_scope = Relation.new(self)
      class << self
        delegate :find, :where, to: :all
      end
    end

    module ClassMethods
      def all
        current_scope
      end
    end

  end
end
