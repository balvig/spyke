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
          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        end
      end

      def collection_path
        '/recipes'
      end

      def resource_path(id)
        "/recipes/#{id}"
      end
    end
  end
end
