require 'spike/relation'

module Spike
  module Scopes
    extend ActiveSupport::Concern

    included do
      class << self
        attr_accessor :current_scope
        delegate :find, :where, to: :all
      end
    end

    module ClassMethods
      def all
        current_scope || Relation.new(self)
      end
    end

  end
end
