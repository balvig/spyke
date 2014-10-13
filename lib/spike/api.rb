require 'faraday'

module Spike
  module Api
    extend ActiveSupport::Concern

    module ClassMethods
      def api
        Faraday.new(url: 'http://sushi.com') do |faraday|
          #faraday.request  :url_encoded             # form-encode POST params
          #faraday.response :logger                  # log requests to STDOUT
          faraday.response  :json
          faraday.adapter   Faraday.default_adapter  # make requests with Net::HTTP
        end
      end

      def collection_path
        "/recipes#{current_scope.to_query}"
      end

      def resource_path(id)
        "/recipes/#{id}"
      end

      def get_resource(id)
        response = api.get(resource_path(id))
        new response.body['result']
      end

      def get_collection
        response = api.get(collection_path)
        return [] unless response.body && response.body['result']
        response.body['result'].map do |record|
          new(record)
        end
      end

    end
  end
end
