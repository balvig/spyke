module Spyke
  module Middleware
    class Logger < Faraday::Response::Middleware

      def initialize(app, logger)
        super(app)
        @logger = logger
      end

      def call(env)
        @logger.formatter = -> (severity, datetime, progname, msg) { msg }
        @logger.debug "\n\n\n\n#{env[:method].upcase} #{env[:url]}"
        @logger.debug "\n  Headers: #{env[:request_headers]}"
        @logger.debug "\n  Body: #{env[:body]}" if env[:body]
        super
      end

      def on_complete(env)
        @logger.debug "\n\nCompleted #{env[:status]}"
        @logger.debug "\n  Headers: #{env[:response_headers]}"
        @logger.debug "\n  Body: #{truncate_binary_values env[:body]}" if env[:body]
      end

      private

        def truncate_binary_values(body)
          body.gsub(/(data:)([^"]+)/, 'data:...')
        end
    end
  end
end
