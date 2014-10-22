module Spike
  class Path
    PLACEHOLDER_FORMAT = /\/:\w+/ # /:recipe_id etc

    attr_reader :path_params
    # TODO PATH PARAMS IS NOT A VARIABLE IT'S A METHOOOOOD

    def initialize(uri_template, params = {})
      @uri_template, @params, @path_params = uri_template, params, []
      @path = compute_path
    end

    def join(other_path)
      self.class.new File.join(@path, other_path.to_s), @params
    end

    def to_s
      @path
    end

    private

      def compute_path
        @uri_template.dup.tap do |path|
          @uri_template.scan(PLACEHOLDER_FORMAT) do |match|
            key = path_stub_to_symbol(match)
            value = @params[key].to_s
            if value.present?
              @path_params << key
              value = '/' + value
            end
            path.sub! match, value
          end
        end
      end

      def path_stub_to_symbol(str)
        str[2..str.length].to_sym
      end
  end
end
