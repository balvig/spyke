module Spyke
  class RfcConverter
    def initialize(input)
      @input = input
    end

    def convert
      output = @input.dup
      output = wrap_required_variables_in_curly_braces(output)
      output = convert_start_parens_curly_braces(output)
      output = convert_end_parens_to_curly_braces(output)
      output = remove_colons(output)
      output
    end

    private
      def wrap_required_variables_in_curly_braces(text)
        text.gsub(/(:\w+(?!\)))\b/, '{\1}')
      end

      def convert_start_parens_curly_braces(text)
        text.gsub('(', '{')
      end

      def convert_end_parens_to_curly_braces(text)
        text.gsub(')', '}')
      end

      def remove_colons(text)
        text.gsub(':', '')
      end
  end
end
