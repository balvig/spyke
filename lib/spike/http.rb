require 'faraday'
require 'spike/config'
require 'spike/result'
require 'spike/route'

module Spike
  module Http
    extend ActiveSupport::Concern

    module ClassMethods

      def request(method, path, params = {})
        route = Route.new(path, params)
        Result.new connection.run_request(method, route.path, nil, nil).body
      end

      def get(path, params = {})
        record_or_collection_from_result get_raw(path, params)
      end

      def get_raw(path, params = {})
        request(:get, path, params)
      end

      def put(path, params = {})
        request :put, path, params
      end

      def new_collection_from_result(result)
        Collection.new result.data.map { |record| new(record) }, result.metadata
      end

      def new_from_result(result)
        new result.data
      end

      def record_or_collection_from_result(result)
        if result.data.is_a?(Array)
          new_collection_from_result(result)
        else
          new_from_result(result)
        end
      end

      private

        def connection
          Config.connection
        end
    end

    def put(path, params = {})
      result = self.class.put [self.class.resource_path, path].join('/'), params.merge(id: id)
      self.attributes = result.data
    end

  end
end
