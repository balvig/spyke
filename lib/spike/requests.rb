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
        Result.new connection.run_request(method, route.path, nil, nil).body
      end

      def get(base_path, params = {})
        build_records_from_result request(:get, base_path, params)
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
      result = self.class.put [self.class.resource_path, path].join('/'), params.merge(id: id)
      self.attributes = result.data
    end

  end
end
