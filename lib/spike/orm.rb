require 'spike/relation'

module Spike
  module Orm
    extend ActiveSupport::Concern

    included do
      define_model_callbacks :create, :update, :save
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

      def uri_template(uri = File.join(model_name.plural, ':id'))
        @uri_template ||= uri
      end
    end

    def persisted?
      id?
    end

    def save
      run_callbacks :save do
        if persisted?
          run_callbacks :update do
            put to_params
          end
        else
          run_callbacks :create do
            self.class.post Path.new(self.class.uri_template), to_params
          end
        end
      end
    end

    def to_params
      { self.class.model_name.param_key => attributes }
    end
  end
end
