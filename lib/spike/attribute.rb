module Spike
  class Attribute

    def self.paramify(attributes)
      parameters = {}
      attributes.each do |key, value|
        parameters[key] = attribute_to_params(value)
      end
      parameters
    end

    def self.attribute_to_params(value)
      value = case
              when value.is_a?(Spike::Base)         then paramify(value.attributes)
              when value.respond_to?(:content_type) then Faraday::UploadIO.new(value.path, value.content_type)
              when value.is_a?(Hash)                then paramify(value)
              when value.is_a?(Array)               then value.map { |v| attribute_to_params(v) }
              else value
              end
    end

  end
end
