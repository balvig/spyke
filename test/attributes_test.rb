require 'test_helper'

module Spike
  class AttributesTest < MiniTest::Test

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

    def test_setters
      recipe = Recipe.new
      recipe.title = 'Sushi'
      assert_equal 'Sushi', recipe.title
    end

  end
end
