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
        debug "  #{color(name, GREEN, true)}  #{color(details, BOLD, true)}"
      end
    end
  end

  Spyke::Instrumentation::LogSubscriber.attach_to :spyke
end
