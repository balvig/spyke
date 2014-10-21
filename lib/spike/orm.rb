require 'spike/relation'

module Spike
  module Orm
    extend ActiveSupport::Concern

    included do
      define_model_callbacks :create, :update, :save

      class_attribute :callback_methods
      self.callback_methods = { create: :post, update: :put }.freeze

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
        self.callback_methods = callback_methods.merge(callback => value) if value
        callback_methods[callback]
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

    def to_params
      { self.class.model_name.param_key => attributes }
    end

  end
end
