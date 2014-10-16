require 'spike/relation'

module Spike
  module Orm
    extend ActiveSupport::Concern

    included do
      class << self
        attr_accessor :current_scope
        delegate :find, :where, to: :all
        delegate :create, to: :all
      end
    end

    module ClassMethods
      def all
        current_scope || Relation.new(self)
      end

      def scope(name, code)
        self.class.send :define_method, name, code
      end
    end

    def save
      if persisted?
        put self.class.resource_path, attributes
      else
        self.class.create attributes
      end
    end

  end
end
