require 'test_helper'

module Spyke
  class AttributesTest < MiniTest::Test

    def test_basics
      attr = Attributes.new(id: 3, 'title' => 'Fish', groups: [ Group.new(name: 'Starter'), { name: 'Dessert' } ])
      assert_equal({ 'id' => 3 , 'title' => 'Fish', 'groups' => [{ 'name' => 'Starter' }, { 'name' => 'Dessert' }] }, attr.to_params)
    end

    def test_predicate_methods
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(result: { id: 1, title: 'Sushi' })

      recipe = Recipe.find(1)

      assert_equal true, recipe.title?
      assert_equal false, recipe.description?
    end

    def test_respond_to
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(result: { id: 1, serves: 3 })

      recipe = Recipe.find(1)

      assert_equal true, recipe.respond_to?(:serves)
      assert_equal false, recipe.respond_to?(:story)
    end

    def test_assigning_attributes
      recipe = Recipe.new(id: 2)
      recipe.attributes = { title: 'Pasta' }

      assert_equal 'Pasta', recipe.title
      assert_equal 2, recipe.id
    end

    def test_removing_id_if_blank_string
      recipe = Recipe.new

      assert_nil recipe.id
      assert_equal({ 'recipe' => {} }, recipe.to_params)

      recipe.id = ''
      assert_nil recipe.id
      assert_equal({ 'recipe' => {} }, recipe.to_params)
    end

    def test_setters
      recipe = Recipe.new
      recipe.title = 'Sushi'
      assert_equal 'Sushi', recipe.title
    end

    def test_equality
      assert_equal Recipe.new(id: 2, title: 'Fish'), Recipe.new(id: 2, title: 'Fish')
      refute_equal Recipe.new(id: 2, title: 'Fish'), Recipe.new(id: 1, title: 'Fish')
      refute_equal Recipe.new(id: 2, title: 'Fish'), 'not_a_spyke_object'
    end

    def test_explicit_attributes
      recipe = Recipe.new
      assert_equal nil, recipe.title
      assert_raises NoMethodError do
        recipe.description
      end

      recipe = Recipe.new(title: 'Fish')
      assert_equal 'Fish', recipe.title
    end

    def test_converting_files_to_faraday_io
      Faraday::UploadIO.stubs(:new).with('/photo.jpg', 'image/jpeg').returns('UploadIO')
      file = mock
      file.stubs(:path).returns('/photo.jpg')
      file.stubs(:content_type).returns('image/jpeg')

      recipe = Recipe.new(image: Image.new(file: file))

      assert_equal 'UploadIO', recipe.image.to_params['image']['file']
      assert_equal 'UploadIO', recipe.to_params['recipe']['image']['file']

      recipe = Recipe.new(image_attributes: { file: file })

      assert_equal 'UploadIO', recipe.image.to_params['image']['file']
      assert_equal 'UploadIO', recipe.to_params['recipe']['image']['file']
    end

    def test_inspect
      recipe = Recipe.new(id: 2, title: 'Pizza', description: 'Delicious')
      assert_equal '#<Recipe(/recipes/2) id: 2 title: "Pizza" description: "Delicious">', recipe.inspect
    end

    def test_rejecting_wrong_number_of_args
      skip 'wishlisted'
      stub_request(:any, /.*/)
      recipe = Recipe.new(description: 'Delicious')
      assert_raises ArgumentError do
        recipe.description(2)
      end
      assert_raises ArgumentError do
        recipe.description?(2)
      end
      assert_raises ArgumentError do
        recipe.image(2)
      end
    end
  end
end
