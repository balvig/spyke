require 'test_helper'

module Spike
  class OrmTest < MiniTest::Test

    def test_find
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(data: { id: 1, title: 'Sushi' })
      stub_request(:get, 'http://sushi.com/users/1').to_return_json(data: { id: 1, name: 'Bob' })

      recipe = Recipe.find(1)
      user = User.find(1)

      assert_equal 1, recipe.id
      assert_equal 'Sushi', recipe.title
      assert_equal 'Bob', user.name
    end

    def test_find_with_slug
      endpoint = stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(data: { id: 1 })
      Recipe.find('1-delicious-soup')
      assert_requested endpoint
    end

    def test_404
      stub_request(:get, 'http://sushi.com/recipes/1').to_return(status: 404)

      assert_raises ResourceNotFound do
        Recipe.find(1)
      end
    end

    def test_save_new_record
      endpoint = stub_request(:post, 'http://sushi.com/recipes').with(body: { recipe: { title: 'Sushi' } }).to_return_json(data: { id: 1, title: 'Sushi (created)' })

      recipe = Recipe.new(title: 'Sushi')
      recipe.save

      assert_equal 'Sushi (created)', recipe.title
      assert_requested endpoint
    end

    def test_save_persisted_record
      endpoint = stub_request(:put, 'http://sushi.com/recipes/1').with(body: { recipe: { id: 1, title: 'Sushi' } }).to_return_json(data: { id: 1, title: 'Sushi (saved)' })

      recipe = Recipe.new(id: 1, title: 'Sashimi')
      recipe.title = 'Sushi'
      recipe.save

      assert_equal 'Sushi (saved)', recipe.title
      assert_requested endpoint
    end

    def test_create
      endpoint = stub_request(:post, 'http://sushi.com/recipes').with(body: { recipe: { title: 'Sushi' } }).to_return_json(data: { id: 1, title: 'Sushi' })

      recipe = Recipe.create(title: 'Sushi')

      assert_equal 'Sushi', recipe.title
      assert_requested endpoint
    end

    def test_create_scoped
      endpoint = stub_request(:post, 'http://sushi.com/recipes').with(body: { recipe: { title: 'Sushi', status: 'published' } })

      Recipe.published.create(title: 'Sushi')

      assert_requested endpoint
    end

    def test_create_association
      endpoint = stub_request(:post, 'http://sushi.com/recipes/1/groups').with(body: { group: { title: 'Topping', recipe_id: 1 } }).to_return_json(data: { title: 'Topping', recipe_id: 1 })

      group = Recipe.new(id: 1).groups.create(title: 'Topping')

      assert_equal 'Topping', group.title
      assert_requested endpoint
    end

    def test_create_scoped_association
      skip
      endpoint = stub_request(:post, 'http://sushi.com/users/1/recipes').with(body: { recipe: { title: 'Sushi', status: 'published' } })

      User.new(id: 1).recipes.published.create(title: 'Sushi')

      assert_requested endpoint
    end

    def test_save_association
      endpoint = stub_request(:post, 'http://sushi.com/recipes/1/groups').with(body: { group: { title: 'Topping', recipe_id: 1 } }).to_return_json(data: { title: 'Topping', recipe_id: 1 })

      group = Recipe.new(id: 1).groups.build(title: 'Topping').save

      assert_equal 'Topping', group.title
      assert_requested endpoint
    end

    def test_find_using_custom_uri_template
      endpoint = stub_request(:get, 'http://sushi.com/images/photos/1').to_return_json(data: { id: 1 })
      Photo.find(1)
      assert_requested endpoint
    end

    def test_create_using_custom_uri_template
      endpoint = stub_request(:post, 'http://sushi.com/images/photos')
      Photo.create
      assert_requested endpoint
    end

    def test_create_using_nested_custom_uri_template
      endpoint = stub_request(:post, 'http://sushi.com/recipes/1/ingredients')
      Ingredient.new(recipe_id: 1).save
      assert_requested endpoint
    end

    def test_create_using_custom_method
      endpoint = stub_request(:put, 'http://sushi.com/images')
      Image.create
      assert_requested endpoint
    end

    def test_inheritance_using_custom_method
      endpoint = stub_request(:put, 'http://sushi.com/step_images')
      StepImage.create
      assert_requested endpoint
    end
  end
end
