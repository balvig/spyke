require 'faraday'
require 'spike/config'
require 'spike/result'
require 'spike/route'

module Spike
  module Requests
    extend ActiveSupport::Concern

    module ClassMethods

      def request(method, base_path, params = {})
        route = Route.new(base_path, params)
        result = Result.new connection.run_request(method, route.path, nil, nil).body
        build_records_from_result(result)
      end

      def get(base_path, params = {})
        request :get, base_path, params
      end

      def put(base_path, params = {})
        request :put, base_path, params
      end

      def build_records_from_result(result)
        if result.data.is_a?(Array)
          Collection.new result.data.map { |record| new(record) }, result.metadata
        elsif result.data
          new result.data
        else
          nil
        end
      end

      def connection
        Config.connection
      end
    end

    def put(path, params = {})
      self.class.put [self.class.resource_path, path].join('/'), params.merge(id: id)
    end

  end
end
