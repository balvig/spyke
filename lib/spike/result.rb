module Spike
  class Result

    attr_reader :body

    def initialize(body)
      @body = HashWithIndifferentAccess.new(body)
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
  end
end
