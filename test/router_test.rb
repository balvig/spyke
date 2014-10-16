require 'test_helper'

module Spike
  class RouterTest < MiniTest::Test
    def test_path
      assert_equal '/recipes', Router.new('/recipes').resolved_path
      assert_equal '/recipes/2', Router.new('/recipes/:id', id: 2).resolved_path
      assert_equal '/users/1/recipes', Router.new('/users/:user_id/recipes', user_id: 1).resolved_path
    end

    def test_params
      router = Router.new('/recipes', public: true)
      assert_equal '/recipes', router.resolved_path
      assert_equal({ public: true }, router.resolved_params)
    end

    def test_params_with_path_params
      router = Router.new('/recipes/:id', id: 2, public: true)
      assert_equal '/recipes/2', router.resolved_path
      assert_equal({ public: true }, router.resolved_params)
    end

  end
end
