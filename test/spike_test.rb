require 'test_helper'

class Recipe
  include Spike::Base
end

class User
  include Spike::Base
end

module Spike
  class SpikeTest < MiniTest::Test
    def test_basic_find
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(data: { id: 1, title: 'Sushi' })

      recipe = Recipe.find(1)

      assert_equal 1, recipe.id
      assert_equal 'Sushi', recipe.title
    end

    def test_slug
      endpoint = stub_request(:get, 'http://sushi.com/recipes/1')

      Recipe.find('1-delicious-soup')

      assert_requested endpoint
    end

    def test_dynamic_resource_path
      stub_request(:get, 'http://sushi.com/users/1').to_return_json(data: { id: 1, name: 'Bob' })

      user = User.find(1)

      assert_equal 'Bob', user.name
    end

    def test_predicate_methods
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(data: { id: 1, title: 'Sushi' })

      recipe = Recipe.find(1)

      assert_equal true, recipe.title?
      assert_equal false, recipe.description?
    end

    def test_respond_to
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(data: { id: 1, title: 'Sushi' })

      recipe = Recipe.find(1)

      assert_equal true, recipe.respond_to?(:title)
      assert_equal false, recipe.respond_to?(:description)
    end

  end
end
