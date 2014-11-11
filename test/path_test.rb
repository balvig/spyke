require 'test_helper'

module Spike
  class PathTest < MiniTest::Test
    def test_collection_path
      assert_equal '/recipes', Path.new('/recipes/:id').to_s
    end

    def test_resource_path
      assert_equal '/recipes/2', Path.new('/recipes/:id', id: 2).to_s
    end

    def test_nested_collection_path
      path = Path.new('/users/:user_id/recipes/:id', user_id: 1, status: 'published')
      assert_equal [:user_id, :id], path.variables
      assert_equal '/users/1/recipes', path.to_s
    end

    def test_nested_resource_path
      assert_equal '/users/1/recipes/2', Path.new('/users/:user_id/recipes/:id', user_id: 1, id: 2).to_s
    end
  end
end
