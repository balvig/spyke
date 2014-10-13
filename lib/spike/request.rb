require 'faraday'

module Spike
  class Request
    class_attribute :connection

    def initialize(method, url)
      @response = connection.get(url)
    end

    def data
      body[:data] || {}
    end

    def metadata
      body[:metadata]
    end

    def errors
      body[:errors]
    end

    private

      def body
        (@response.body || {}).deep_symbolize_keys
      end


  end
end
