module Spyke
  module Instrumentation
    module ControllerRuntime
      extend ActiveSupport::Concern

      protected

        attr_internal :spyke_runtime

        def process_action(action, *args)
          Spyke::Instrumentation::LogSubscriber.reset_runtime
          super
        end

        def cleanup_view_runtime
          spyke_runtime_before_render = Spyke::Instrumentation::LogSubscriber.reset_runtime
          self.spyke_runtime = (spyke_runtime || 0) + spyke_runtime_before_render
          runtime = super
          spyke_runtime_after_render = Spyke::Instrumentation::LogSubscriber.reset_runtime
          self.spyke_runtime += spyke_runtime_after_render
          runtime - spyke_runtime_after_render
        end

        def append_info_to_payload(payload)
          super
          payload[:spyke_runtime] = (spyke_runtime || 0) + Spyke::Instrumentation::LogSubscriber.reset_runtime
        end

        module ClassMethods
          def log_process_action(payload)
            messages, spyke_runtime = super, payload[:spyke_runtime]
            messages << ("Spyke: %.1fms" % spyke_runtime.to_f) if spyke_runtime
            messages
          end
        end
    end
  end
end
