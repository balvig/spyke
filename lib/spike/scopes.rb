require 'spike/relation'

module Spike
  module Scopes
    extend ActiveSupport::Concern

    included do
      class << self
        attr_writer :current_scope # TODO: Need to check thread safety for this
        delegate :all, :find, :where, to: :current_scope
      end
    end

    module ClassMethods
      def scope(name, code)
        self.class.send :define_method, name, code
      end

      def current_scope
        @current_scope || Relation.new(self, uri_template: uri_template)
      end
    end
  end
end
