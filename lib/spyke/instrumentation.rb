require 'spyke/instrumentation/log_subscriber'
require 'spyke/instrumentation/controller_runtime'

Spyke::Instrumentation::LogSubscriber.attach_to :spyke

ActiveSupport.on_load(:action_controller) do
  include Spyke::Instrumentation::ControllerRuntime
end
