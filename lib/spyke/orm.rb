module Spyke
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

      def find(id)
        raise ResourceNotFound if id.blank?
        id = strip_slug(id)
        where(id: id).find_one || raise(ResourceNotFound)
      end

      def fetch
        scoped_request :get
      end

      def create(attributes = {})
        record = new(attributes)
        record.save
        record
      end

      def destroy(id = nil)
        new(id: id).destroy
      end

      def strip_slug(id)
        id.to_s.split('-').first
      end
    end

    def to_params
      if param_root
        { param_root => params_not_embedded_in_url }
      else
        params_not_embedded_in_url
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
      delete
    end

    def update_attributes(new_attributes)
      self.attributes = new_attributes
      save
    end

    def reload
      self.attributes = self.class.find(id).attributes
    end

    private

      def param_root
        if include_root.is_a? String
          include_root
        elsif include_root?
          self.class.model_name.param_key
        end
      end

      def params_not_embedded_in_url
        attributes.to_params.except(*uri.variables)
      end
  end
end
