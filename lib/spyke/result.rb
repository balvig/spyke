module Spyke
  class Result
    attr_reader :data, :metadata, :errors

    def self.new_from_response_body(body, data_key:, metadata_key:, errors_key:)
      body = HashWithIndifferentAccess.new(body.presence)
      new(
        data: body[data_key],
        metadata: body[metadata_key],
        errors: body[errors_key]
      )
    end

    def initialize(data:, metadata: nil, errors: nil)
      @data = data
      @metadata = metadata || {}
      @errors = errors || []
    end
  end
end
