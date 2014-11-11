require 'spike/relation'
require 'spike/scope_registry'

module Spike
  module Scopes
    extend ActiveSupport::Concern

    module ClassMethods
      delegate :all, :where, to: :current_scope

      def scope(name, code)
        self.class.send :define_method, name, code
      end

      def current_scope=(scope)
        ScopeRegistry.set_value_for(:current_scope, name, scope)
      end

      def current_scope
        ScopeRegistry.value_for(:current_scope, name) || Relation.new(self, uri_template: uri_template)
      end
    end

    private

      def current_scope
        self.class.current_scope
      end
  end
end
