require 'uri_template'

module Spyke
  class Path
    def initialize(uri_template, params = {})
      @uri_template = URITemplate.new(:colon, uri_template)
      @params = params
    end

    def join(other_path)
      self.class.new File.join(path, other_path.to_s), @params
    end

    def to_s
      path
    end

    def variables
      @variables ||= @uri_template.variables.map(&:to_sym)
    end

    private

      def path
        @uri_template.expand(@params).chomp('/')
      end
  end
end
