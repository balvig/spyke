require 'spike/associations/association'
require 'spike/path'

module Spike
  module Associations
    class HasMany < Association

      def initialize(*args)
        super
        @options[:uri_template] ||= File.join parent.class.model_name.plural, ":#{foreign_key}", klass.model_name.plural, ':id'
        @params[foreign_key] = parent.try(:id)
      end

      def activate
        self
      end

      def new(attributes = {})
        super attributes.merge(params)
      end

      def create(attributes = {})
        klass.post path, new(attributes).to_params
      end

    end
  end
end
