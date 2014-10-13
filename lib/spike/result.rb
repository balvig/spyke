module Spike
  class Result

    attr_reader :body

    def initialize(body)
      @body = (body || {}).deep_symbolize_keys
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
