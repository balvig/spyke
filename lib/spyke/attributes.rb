module Spyke
  class Attributes < HashWithIndifferentAccess
    def to_params
      each_with_object({}) do |(key, value), parameters|
        parameters[key] = parse_value(value)
      end.with_indifferent_access
    end

    private

      def parse_value(value)
        case
        when value.is_a?(Spyke::Base)         then value.attributes.to_params
        when value.is_a?(Array)               then value.map { |v| parse_value(v) }
        when value.respond_to?(:content_type) then Faraday::UploadIO.new(value.path, value.content_type)
        else value
        end
      end
  end
end
