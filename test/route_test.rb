require 'test_helper'

module Spike
  class RouteTest < MiniTest::Test
    def test_path
      assert_equal '/recipes', Route.new('/recipes').path
      assert_equal '/recipes?public=true', Route.new('/recipes', public: true).path
      assert_equal '/recipes/2', Route.new('/recipes/:id', id: 2).path
      assert_equal '/recipes/2?public=true', Route.new('/recipes/:id', id: 2, public: true).path
      assert_equal '/users/1/recipes', Route.new('/users/:user_id/recipes', user_id: 1).path
    end
  end
end
