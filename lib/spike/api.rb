module Spike
  module Api
    extend ActiveSupport::Concern

    module ClassMethods
      def get(base_path, params = {})
        build_records_from_result Request.new(base_path, params).result
      end

      def build_records_from_result(result)
        if result.data.is_a?(Array)
          Collection.new result.data.map { |record| new(record) }, result.metadata
        elsif result.data
          new result.data
        else
          nil
        end
      end
    end
  end
end
