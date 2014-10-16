require 'faraday'
require 'spike/config'
require 'spike/result'
require 'spike/router'

module Spike
  module Http
    extend ActiveSupport::Concern
    METHODS = %i{ get post put patch delete }

    module ClassMethods

      METHODS.each do |method|
        define_method(method) do |path, params = {}|
          new_or_collection_from_result send("#{method}_raw", path, params)
        end

        define_method("#{method}_raw") do |path, params = {}|
          request(method, path, params)
        end
      end

      def request(method, path, params = {})
        response = connection.send(method) do |request|
          router = Router.new(path, params)
          request.url router.resolved_path, router.resolved_params
        end
        Result.new_from_response(response)
      end

      def new_or_collection_from_result(result)
        if result.data.is_a?(Array)
          new_collection_from_result(result)
        else
          new_from_result(result)
        end
      end

      def new_from_result(result)
        new result.data
      end

      def new_collection_from_result(result)
        Collection.new result.data.map { |record| new(record) }, result.metadata
      end

      private

        def connection
          Config.connection
        end
    end

    def put(path, params = {})
      result = self.class.put_raw File.join(self.class.resource_path, path.to_s), params.merge(id: id)
      self.attributes = result.data
    end

  end
end
