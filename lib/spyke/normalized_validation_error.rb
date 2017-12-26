module Spyke
  class NormalizedValidationError
    ERROR_KEY = :error

    def initialize(attributes)
      @attributes = attributes
    end

    def message
      case @attributes
      when String
        @attributes
      when Hash
        @attributes[ERROR_KEY].to_sym
      end
    end

    def options
      case @attributes
      when String
        {}
      when Hash
        @attributes.except(ERROR_KEY).symbolize_keys
      end
    end
  end
end
