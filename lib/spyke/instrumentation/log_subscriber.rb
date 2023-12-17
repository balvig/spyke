module Spyke
  module Instrumentation
    class LogSubscriber < ActiveSupport::LogSubscriber
      def self.runtime=(value)
        Thread.current['spyke_request_runtime'] = value
      end

      def self.runtime
        Thread.current['spyke_request_runtime'] ||= 0
      end

      def self.reset_runtime
        rt, self.runtime = runtime, 0
        rt
      end

      def request(event)
        return unless logger.debug?
        self.class.runtime += event.duration
        name = '%s (%.1fms)' % ["Spyke", event.duration]
        details = "#{event.payload[:method].upcase} #{event.payload[:url]} [#{event.payload[:status]}]"
        debug "  #{color(name, GREEN, backwards_compatible_bold)}  #{color(details, nil, backwards_compatible_bold)}"
      end

      private

        def backwards_compatible_bold
          if ActiveSupport.gem_version < Gem::Version.new("7.1.0")
            true
          else
            { bold: true }
          end
        end
    end
  end
end
