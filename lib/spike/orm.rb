require 'spike/relation'

module Spike
  module Orm
    extend ActiveSupport::Concern

    included do
      define_model_callbacks :create, :update, :save

      class << self
        attr_accessor :current_scope # TODO: Need to check thread safety for this
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

      def method_for(callback, value = nil)
        @callback_methods ||= { create: :post, update: :put }
        @callback_methods[callback] = value || @callback_methods[callback]
      end
    end

    def persisted?
      id?
    end

    def save
      run_callbacks :save do
        if persisted?
          run_callbacks :update do
            send self.class.method_for(:update), element_path, to_params
          end
        else
          run_callbacks :create do
            send self.class.method_for(:create), collection_path, to_params
          end
        end
      end
    end

    def to_params
      { self.class.model_name.param_key => attributes }
    end

  end
end
