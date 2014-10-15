require 'test_helper'

module Spike
  class CustomRequestTest < MiniTest::Test
    def test_custom_request_from_class
      endpoint = stub_request(:get, 'http://sushi.com/recipes/recent').to_return_json(data: [{ id: 1, title: 'Bread' }])

      assert_equal %w{ Bread }, Recipe.recent.map(&:title)

      assert_requested endpoint
    end
  end
end
