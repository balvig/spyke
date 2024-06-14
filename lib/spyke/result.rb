module Spyke
  class Result
    attr_reader :body

    def self.new_from_response(response)
      new(response.body)
    end

    def initialize(body)
      @body = body.respond_to?(:to_hash) ? HashWithIndifferentAccess.new(body) : HashWithIndifferentAccess.new({})
    end

    def data
      body[:data]
    end

    def metadata
      body[:metadata] || {}
    end

    def errors
      body[:errors] || []
    end
  end
end
