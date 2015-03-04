require 'spyke/relation'
require 'spyke/scope_registry'

module Spyke
  module Scoping
    extend ActiveSupport::Concern

    module ClassMethods
      delegate :where, :build, :any?, :empty?, to: :all
      delegate :using, to: :all

      def all
        current_scope || Relation.new(self, uri: uri)
      end

      def scope(name, code)
        define_singleton_method name, code
      end

      def current_scope=(scope)
        ScopeRegistry.set_value_for(:current_scope, name, scope)
      end

      def current_scope
        ScopeRegistry.value_for(:current_scope, name)
      end
    end

    private

      def scope
        @scope ||= self.class.all
      end
  end
end
