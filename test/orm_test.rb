require 'test_helper'

module Spike
  class OrmTest < MiniTest::Test
    def test_save_on_new_record
      endpoint = stub_request(:post, 'http://sushi.com/recipes').with(title: 'Sushi').to_return_json(data: { id: 1, title: 'Sushi' })

      recipe = Recipe.new(title: 'Sushi')
      recipe.save

      assert_equal 'Sushi', recipe.title
      assert_requested endpoint
    end

    def test_save_on_persisted_record
      endpoint = stub_request(:put, 'http://sushi.com/recipes/1').with(title: 'Sushi').to_return_json(data: { id: 1, title: 'Sushi' })

      recipe = Recipe.new(id: 1, title: 'Sashimi')
      recipe.title = 'Sushi'
      recipe.save

      assert_equal 'Sushi', recipe.title
      assert_requested endpoint
    end

    def test_create
      endpoint = stub_request(:post, 'http://sushi.com/recipes').with(title: 'Sushi').to_return_json(data: { id: 1, title: 'Sushi' })

      recipe = Recipe.create(title: 'Sushi')

      assert_equal 'Sushi', recipe.title
      assert_requested endpoint
    end
  end
end
