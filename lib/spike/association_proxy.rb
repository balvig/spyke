require 'spike/relation'
require 'spike/result'

module Spike
  class AssociationProxy < Relation

    def initialize(model, name:, **options)
      @model, @name, @options = model, name, options
      @params = { model_key => @model.try(:id) }
    end

    def collection_path
      [@model.class.base_path, ":#{model_key}", klass.collection_path].join('/')
    end

    private

      def klass
        (@options[:class_name] || @name.to_s).classify.constantize
      end

      def fetch(path)
        fetch_embedded || super
      end

      def fetch_embedded
        Result.new(data: embedded_result) if embedded_result
      end

      def embedded_result
        @model.attributes[@name]
      end

      def model_key
        "#{@model.class.model_name.param_key}_id"
      end

  end
end
