require 'faraday'
require 'spike/config'
require 'spike/result'

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
            request.url path.to_s, params
          else
            request.url path.to_s
            request.body = params
          end
        end
        Result.new_from_response(response)
      end

      def connection
        Config.connection
      end

      def uri_template(uri = File.join('/', model_name.plural, ':id'))
        @uri_template ||= uri
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
