require 'faraday'
require 'spike/result'

module Spike
  class Request
    class_attribute :connection

    def initialize(base_path, params = {})
      @base_path, @params = base_path, params
    end

    def result
      @result ||= Result.new(connection.get(path).body)
    end

    def path
      "#{path_with_params}#{query_string}"
    end

    private

      def params_in_path
        @params.select { |key| @base_path.include?(":#{key}") }
      end

      def params_in_query
        @params.reject { |key| params_in_path.has_key?(key) }
      end

      def query_string
        "?#{params_in_query.to_query}" if params_in_query.any?
      end

      def path_with_params
        path = @base_path.dup
        params_in_path.each do |key, value|
          path.sub!(":#{key}", value.to_s)
        end
        path
      end

  end
end
