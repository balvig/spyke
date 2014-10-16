module Spike
  class Router

    def initialize(path, params = {})
      @path, @params =  path, params
    end

    def resolved_path
      path = @path.dup
      params_in_path.each do |key, value|
        path.sub!(":#{key}", value.to_s)
      end
      path
    end

    def resolved_params
      @params.reject { |key| params_in_path.has_key?(key) }
    end

    private

      def params_in_path
        @params.select { |key| @path.include?(":#{key}") }
      end

  end
end
