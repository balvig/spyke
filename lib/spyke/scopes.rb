require 'spyke/relation'
require 'spyke/scope_registry'

module Spyke
  module Scopes
    extend ActiveSupport::Concern

    module ClassMethods
      delegate :all, :where, to: :current_scope

      def scope(name, code)
        (class << self; self end).send :define_method, name, code
      end

      def current_scope=(scope)
        ScopeRegistry.set_value_for(:current_scope, name, scope)
      end

      def current_scope
        ScopeRegistry.value_for(:current_scope, name) || Relation.new(self, uri: uri)
      end
    end

    private

      def current_scope
        self.class.current_scope
      end
  end
end
