module Spike
  class Path
    PLACEHOLDER_FORMAT = /\/:\w+/ # /:recipe_id etc

    def initialize(uri_template, params = {})
      @uri_template, @params = uri_template, params
    end

    def to_s
      @uri_template.dup.tap do |path|
        @uri_template.scan(PLACEHOLDER_FORMAT) do |match|
          value = @params[path_stub_to_symbol(match)].to_s
          value = '/' + value if value.present?
          path.sub! match, value
        end
      end
    end

    private

      def path_stub_to_symbol(str)
        str[2..str.length].to_sym
      end
  end
end
