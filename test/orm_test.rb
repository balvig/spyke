require 'test_helper'

module Spike
  class OrmTest < MiniTest::Test

    def test_save_new_record
      endpoint = stub_request(:post, 'http://sushi.com/recipes').with(body: { recipe: { title: 'Sushi' } }).to_return_json(data: { id: 1, title: 'Sushi' })

      recipe = Recipe.new(title: 'Sushi')
      recipe.save

      assert_equal 'Sushi', recipe.title
      assert_requested endpoint
    end

    def test_save_persisted_record
      endpoint = stub_request(:put, 'http://sushi.com/recipes/1').with(body: { recipe: { id: 1, title: 'Sushi' } }).to_return_json(data: { id: 1, title: 'Sushi' })

      recipe = Recipe.new(id: 1, title: 'Sashimi')
      recipe.title = 'Sushi'
      recipe.save

      assert_equal 'Sushi', recipe.title
      assert_requested endpoint
    end

    def test_create
      endpoint = stub_request(:post, 'http://sushi.com/recipes').with(body: { recipe: { title: 'Sushi' } }).to_return_json(data: { id: 1, title: 'Sushi' })

      recipe = Recipe.create(title: 'Sushi')

      assert_equal 'Sushi', recipe.title
      assert_requested endpoint
    end

    def test_create_association
      endpoint = stub_request(:post, 'http://sushi.com/recipes/1/groups').with(body: { group: { title: 'Topping', recipe_id: 1 } }).to_return_json(data: { title: 'Topping', recipe_id: 1 })

      group = Recipe.new(id: 1).groups.create(title: 'Topping')

      assert_equal 'Topping', group.title
      assert_requested endpoint
    end

  end
end
