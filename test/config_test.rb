require 'test_helper'

module Spyke
  class ConfigConnectionWarnTest < MiniTest::Test
    def test_config_connection_warn
      assert_output '', "[DEPRECATION] `Spyke::Config.connection=` is deprecated.  Please use `Spyke::Base.connection=` instead.\n" do
        Spyke::Config.connection = Spyke::Base.connection
      end
    end
  end
end
