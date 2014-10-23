require 'spike/attribute'

module Spike
  module Orm
    extend ActiveSupport::Concern

    included do
      define_model_callbacks :create, :update, :save

      class_attribute :callback_methods
      self.callback_methods = { create: :post, update: :put }.freeze
    end

    module ClassMethods
      def method_for(callback, value = nil)
        self.callback_methods = callback_methods.merge(callback => value) if value
        callback_methods[callback]
      end

      def create(attributes = {})
        record = new(attributes)
        record.save
        record
      end

      def destroy(id = nil)
        new(id: id).destroy
      end

      def build(attributes = {})
        new(attributes)
      end

      def fetch
        path = new.uri
        get_raw path, current_scope.params.except(*path.path_params)
      end
    end

    def persisted?
      id?
    end

    def save
      run_callbacks :save do
        if persisted?
          run_callbacks :update do
            send self.class.method_for(:update), to_params
          end
        else
          run_callbacks :create do
            send self.class.method_for(:create), to_params
          end
        end
      end
    end

    def destroy
      delete to_params
    end

    def to_params
      { self.class.model_name.param_key => attributes.except(*uri.path_params) }
    end

  end
end
