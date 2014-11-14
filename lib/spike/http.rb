require 'faraday'
require 'spike/config'
require 'spike/path'
require 'spike/result'

module Spike
  module Http
    extend ActiveSupport::Concern
    METHODS = %i{ get post put patch delete }

    included do
    end

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
            request.url path.to_s, params
          else
            request.url path.to_s
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
        new result.data if result.data
      end

      def new_collection_from_result(result)
        Collection.new Array(result.data).map { |record| new(record) }, result.metadata
      end

      def uri(uri_template = "/#{model_name.plural}/:id")
        @uri ||= uri_template
      end

      def connection
        Config.connection
      end
    end

    METHODS.each do |method|
      define_method(method) do |action = nil, params = {}|
        params = action if action.is_a?(Hash)
        path = case action
               when Symbol then uri.join(action)
               when String then Path.new(action, attributes)
               else uri
               end
        self.attributes = self.class.send("#{method}_raw", path, params).data
      end
    end

    def uri
      Path.new(@uri_template, attributes)
    end
  end
end
