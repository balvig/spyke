require 'uri_template'

module Spyke
  class InvalidPathError < StandardError; end
  class Path

    def initialize(pattern, params = {})
      @pattern = pattern
      @params = params.symbolize_keys
    end

    def join(other_path)
      self.class.new File.join(path, other_path.to_s), @params
    end

    def to_s
      path
    end

    def variables
      @variables ||= uri_template.variables.map(&:to_sym)
    end

    private

      def uri_template
        @uri_template ||= URITemplate.new(:colon, pattern_with_rfc_style_parens)
      end

      def pattern_with_rfc_style_parens
        @pattern.gsub('(', '{').gsub(')', '}')
      end

      def path
        validate_required_params!
        uri_template.expand(@params).chomp('/')
      end

      def validate_required_params!
        if missing_required_params.any?
          raise Spyke::InvalidPathError, "Missing required params: #{missing_required_params.join(', ')} in #{@pattern}. Mark optional params with parens eg: (:param)"
        end
      end

      def missing_required_params
        required_params - params_with_values
      end

      def params_with_values
        @params.map do |key, value|
          key if value.present?
        end.compact
      end

      def required_params
        @pattern.scan(/\/:(\w+)/).flatten.map(&:to_sym)
      end
  end
end
