require 'test_helper'

module Spike
  class CustomRequestTest < MiniTest::Test
    def test_custom_request_from_class
      endpoint = stub_request(:get, 'http://sushi.com/recipes/recent')

      Recipe.recent.to_a

      assert_requested endpoint
    end
  end
end
