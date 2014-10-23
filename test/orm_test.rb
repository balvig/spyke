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
      stub_request(:get, 'http://sushi.com/recipes/1').to_return(status: 404, body: { message: 'Not found' }.to_json )

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
      stub_request(:put, /.*/)
      endpoint = stub_request(:put, 'http://sushi.com/recipes/1').with(body: { recipe: { title: 'Sushi' } }).to_return_json(data: { id: 1, title: 'Sushi (saved)' })

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

    def test_destroy
      endpoint = stub_request(:delete, 'http://sushi.com/recipes/1')
      Recipe.new(id: 1).destroy
      assert_requested endpoint
    end

    def test_destroy_class_method
      endpoint = stub_request(:delete, 'http://sushi.com/recipes/1')
      Recipe.destroy(1)
      assert_requested endpoint
    end

    def test_scoped_destroy_class_method
      endpoint = stub_request(:delete, 'http://sushi.com/recipes/1/ingredients/2')
      Ingredient.where(recipe_id: 1).destroy(2)
      assert_requested endpoint
    end

    def test_scoped_destroy_class_method_without_param
      endpoint = stub_request(:delete, 'http://sushi.com/recipes/1/image')
      RecipeImage.where(recipe_id: 1).destroy
      assert_requested endpoint
    end

    def test_validations
      assert_equal false, RecipeImage.new.valid?
      assert_equal true, RecipeImage.new(url: 'bob.jpg').valid?
    end

  end
end
