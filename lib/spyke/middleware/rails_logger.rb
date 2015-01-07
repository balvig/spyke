module Spyke
  module Middleware
    class RailsLogger < Faraday::Middleware
      CLEAR   = "\e[0m"
      BOLD    = "\e[1m"
      MAGENTA = "\e[35m"

      def call(env)
        logger.formatter = -> (severity, datetime, progname, msg) { msg }

        logger.debug "\n\n\n\n#{env[:method].upcase} #{env[:url]}"
        logger.debug "\n  Headers: #{env[:request_headers]}"
        logger.debug "\n  Body: #{env[:body]}" if env[:body]

        @app.call(env).on_complete do
          logger.debug "\n\nCompleted #{env[:status]}"
          logger.debug "\n  Headers: #{env[:response_headers]}"
          logger.debug "\n  Body: #{truncate_binary_values env[:body]}" if env[:body]
        end
      end

      private

        def logger
          @logger ||= Logger.new Rails.root.join('log', 'faraday.log')
        end

        def truncate_binary_values(body)
          body.gsub(/(data:)([^"]+)/, 'data:...')
        end
    end
  end
end
