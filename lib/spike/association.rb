require 'spike/relation'
require 'spike/result'

module Spike
  class Association < Relation

    def initialize(owner, name)
      @owner, @name = owner, name
      @params = { owner_key => @owner.try(:id) }
    end

    def collection_path
      "#{@owner.class.base_path}/:#{owner_key}#{klass.collection_path}"
    end

    private

      def klass
        @klass ||= @name.to_s.classify.constantize
      end

      def fetch(path)
        fetch_embedded || super
      end

      def fetch_embedded
        Result.new(data: embedded_result) if embedded_result
      end

      def embedded_result
        @owner.attributes[@name]
      end

      def owner_key
        @owner.class.model_name.param_key
      end

  end
end
