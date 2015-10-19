require 'test_helper'

module Spyke
  class OrmTest < MiniTest::Test
    def test_find
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(result: { id: 1, title: 'Sushi' })
      stub_request(:get, 'http://sushi.com/users/1').to_return_json(result: { id: 1, name: 'Bob' })

      recipe = Recipe.find(1)
      user = User.find(1)

      assert_equal 1, recipe.id
      assert_equal 'Sushi', recipe.title
      assert_equal 'Bob', user.name
    end

    def test_reload
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(result: { id: 1, title: 'Sushi' })

      recipe = Recipe.find(1)
      assert_equal 'Sushi', recipe.title

      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(result: { id: 1, title: 'Sashimi' })
      recipe.reload
      assert_equal 'Sashimi', recipe.title
    end

    def test_404
      stub_request(:get, 'http://sushi.com/recipes/1').to_return(status: 404, body: { message: 'Not found' }.to_json)

      assert_raises(ResourceNotFound) { Recipe.find(1) }
      assert_raises(ResourceNotFound) { Recipe.find(nil) }
      assert_raises(ResourceNotFound) { Recipe.find('') }
    end

    def test_save_new_record
      endpoint = stub_request(:post, 'http://sushi.com/recipes').with(body: { recipe: { title: 'Sushi' } }).to_return_json(result: { id: 1, title: 'Sushi (created)' })

      recipe = Recipe.new(title: 'Sushi')
      recipe.save

      assert_equal 'Sushi (created)', recipe.title
      assert_requested endpoint
    end

    def test_save_persisted_record
      endpoint = stub_request(:put, 'http://sushi.com/recipes/1').with(body: { recipe: { title: 'Sushi' } }).to_return_json(result: { id: 1, title: 'Sushi (saved)' })

      recipe = Recipe.new(id: 1, title: 'Sashimi')
      recipe.title = 'Sushi'
      recipe.save

      assert_equal 'Sushi (saved)', recipe.title
      assert_requested endpoint
    end

    def test_update_attributes
      endpoint = stub_request(:put, 'http://sushi.com/recipes/1').with(body: { recipe: { title: 'Sushi' } }).to_return_json(result: { id: 1, title: 'Sushi (saved)' })

      recipe = Recipe.new(id: 1, title: 'Sashimi')
      recipe.update_attributes(title: 'Sushi')

      assert_equal 'Sushi (saved)', recipe.title
      assert_requested endpoint
    end

    def test_update
      endpoint = stub_request(:put, 'http://sushi.com/recipes/1').with(body: { recipe: { title: 'Sushi' } }).to_return_json(result: { id: 1, title: 'Sushi (saved)' })

      recipe = Recipe.new(id: 1, title: 'Sashimi')
      recipe.update(title: 'Sushi')

      assert_equal 'Sushi (saved)', recipe.title
      assert_requested endpoint
    end

    def test_create
      endpoint = stub_request(:post, 'http://sushi.com/recipes').with(body: { recipe: { title: 'Sushi' } }).to_return_json(result: { id: 1, title: 'Sushi' })

      recipe = Recipe.create(title: 'Sushi')

      assert_equal 'Sushi', recipe.title
      assert_requested endpoint
    end

    def test_create_with_server_returning_validation_errors
      endpoint = stub_request(:put, 'http://sushi.com/recipes/1').to_return_json(id: 'write_error:400', errors: { title: [{ error: 'too_short', count: 4 }], groups: [{ error: 'blank' }] })

      recipe = Recipe.create(id: 1, title: 'sus')

      assert_equal 'sus', recipe.title
      assert_equal ['Title is too short (minimum is 4 characters)', "Groups can't be blank"], recipe.errors.full_messages
      assert_requested endpoint
    end

    def test_find_using_custom_uri_template
      endpoint = stub_request(:get, 'http://sushi.com/images/photos/1').to_return_json(result: { id: 1 })
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

    def test_inheritance_not_overwriting_custom_uri
      endpoint = stub_request(:put, 'http://sushi.com/recipes/1/image')
      RecipeImage.where(recipe_id: 1).create
      assert_requested endpoint
    end

    def test_to_params_without_root
      assert_equal({ 'url' => 'bob.jpg' }, RecipeImage.new(url: 'bob.jpg').to_params)
    end

    def test_to_params_with_custom_root
      assert_equal({ 'step_image_root' => { 'url' => 'bob.jpg' } }, StepImage.new(url: 'bob.jpg').to_params)
      assert_equal({ 'foto' => { 'url' => 'bob.jpg' } }, Cookbook::Photo.new(url: 'bob.jpg').to_params)
    end

    def test_destroy
      endpoint = stub_request(:delete, 'http://sushi.com/recipes/1').to_return_json(result: { id: 1, deleted: true })
      recipe = Recipe.new(id: 1)
      recipe.destroy
      assert recipe.deleted
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

    def test_relative_uris
      previous = Spyke::TestConnection.url_prefix
      Spyke::TestConnection.url_prefix = 'http://sushi.com/api/v2/'

      endpoint = stub_request(:get, 'http://sushi.com/api/v2/recipes')
      Recipe.all.to_a
      assert_requested endpoint

      Spyke::TestConnection.url_prefix = previous
    end

    def test_custom_primary_key_on_collection
      endpoint = stub_request(:get, 'http://sushi.com/users').to_return_json(result: [{ uuid: 1 }])
      user = User.all.first
      assert_requested endpoint
      assert_equal 1, user.id
      assert_equal 1, user.uuid
    end

    def test_custom_primary_key_and_id_are_the_same
      endpoint = stub_request(:get, 'http://sushi.com/users').to_return_json(result: [{ uuid: 1 }])
      user = User.all.first
      assert_requested endpoint
      assert_equal 1, user.id
      assert_equal 1, user.uuid
      assert_equal({ "uuid" => 1 }, user.attributes)
    end

    def test_custom_primary_key_with_response_that_also_has_id_attribute
      endpoint = stub_request(:get, 'http://sushi.com/users').to_return_json(result: [{ uuid: 1, id: 42 }])
      user = User.all.to_a.first
      assert_requested endpoint

      assert_equal 1, user.id
      assert_equal 1, user.uuid
      assert_equal 1, user[:uuid]
      assert_equal 42, user[:id]
    end
  end
end
