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
          if method == :get
            request.url path, params
          else
            request.url path
            request.body = params
          end
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
      if path.is_a?(Symbol)
        path = Path.new(self, id: id)
          #File.join(self.class.resource_path, path.to_s)
        #params.merge!(id: id)
      end
      self.attributes = self.class.put_raw(path, params).data
    end

  end
end
