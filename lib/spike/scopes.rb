require 'spike/scope'

module Spike
  module Scopes
    extend ActiveSupport::Concern

    included do
      class_attribute :current_scope
      self.current_scope = Scope.new(self)
      class << self
        delegate :find, :all, :where, to: :current_scope
      end
    end

  end
end
