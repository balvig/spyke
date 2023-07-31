require 'test_helper'

module Spyke
  class ScopeRegistryTest < Minitest::Test
    def test_setting_and_fetching_values
      ScopeRegistry.set_value_for('foo', 'bar', 1)

      assert_equal 1, ScopeRegistry.value_for('foo', 'bar')
    end
  end
end
