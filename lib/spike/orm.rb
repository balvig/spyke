module Spike
  module Orm
    extend ActiveSupport::Concern

    included do
      define_model_callbacks :create, :update, :save

      class_attribute :include_root
      self.include_root = true

      class_attribute :callback_methods
      self.callback_methods = { create: :post, update: :put }.freeze
    end

    module ClassMethods
      def include_root_in_json(value)
        self.include_root = value
      end

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

    def to_params
      if include_root?
        { self.class.model_name.param_key => attributes.except(*uri.path_params) }
      else
        attributes.except(*uri.path_params)
      end
    end

    def persisted?
      id?
    end

    def save
      run_callbacks :save do
        callback = persisted? ? :update : :create
        run_callbacks(callback) do
          send self.class.method_for(callback), to_params
        end
      end
    end

    def destroy
      delete to_params
    end
  end
end
