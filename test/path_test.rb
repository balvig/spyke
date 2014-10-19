require 'test_helper'

module Spike
  class PathTest < MiniTest::Test

    def test_path_resolving
      assert_equal '/recipes', Path.new('/recipes').to_s
      assert_equal '/recipes/2', Path.new('/recipes/:id', id: 2).to_s
      assert_equal '/users/1/recipes', Path.new('/users/:user_id/recipes/:id', user_id: 1).to_s
      assert_equal '/users/1/recipes/2', Path.new('/users/:user_id/recipes/:id', user_id: 1, id: 2).to_s
    end

  end
end
