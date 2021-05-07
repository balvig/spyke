require 'test_helper'

module Spyke
  class AttributesTest < MiniTest::Test
    def test_block_initialization
      recipe = Recipe.new do |r|
        r.title = 'Sushi'
        r.description = 'Tasty'
      end
      assert_equal 'Sushi', recipe.title
      assert_equal 'Tasty', recipe.description
    end

    def test_initializing_using_permitted_strong_params
      ingredient = Ingredient.new(strong_params(name: 'Flour').permit!)

      assert_equal 'Flour', ingredient.name
    end

    def test_initializing_using_unpermitted_strong_params
      assert_raises ActionController::UnfilteredParameters do
        Ingredient.new(strong_params(name: 'Flour'))
      end
    end

    def test_to_params
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

    def test_attributes_element_reference
      recipe = Recipe.new(title: 'Chicken Soup')

      assert_equal 'Chicken Soup', recipe[:title]
    end

    def test_attributes_element_assignment
      recipe = Recipe.new
      recipe[:title] = 'Beef Brisket'

      assert_equal 'Beef Brisket', recipe.title
    end

    def test_equality
      assert_equal Recipe.new(id: 2, title: 'Fish'), Recipe.new(id: 2, title: 'Fish')
      refute_equal Recipe.new(id: 2, title: 'Fish'), Recipe.new(id: 1, title: 'Fish')
      refute_equal Recipe.new(id: 2, title: 'Fish'), 'not_a_spyke_object'
      refute_equal Recipe.new(id: 2, title: 'Fish'), Image.new(id: 2, title: 'Fish')
      refute_equal Recipe.new, Recipe.new
      refute_equal StepImage.new(id: 1), Image.new(id: 1)
    end

    def test_uniqueness
      recipe_1 = Recipe.new(id: 1)
      recipe_2 = Recipe.new(id: 1)
      recipe_3 = Recipe.new(id: 2)
      image_1 = Image.new(id: 2)
      records = [recipe_1, recipe_2, recipe_3, image_1]
      assert_equal [recipe_1, recipe_3, image_1], records.uniq
    end

    def test_explicit_attributes
      recipe = Recipe.new
      assert_nil recipe.title
      assert_raises NoMethodError do
        recipe.not_set
      end

      recipe = Recipe.new(title: 'Fish')
      assert_equal 'Fish', recipe.title
    end

    def test_super_with_explicit_attributes
      assert_nil Recipe.new.description
    end

    def test_inheriting_explicit_attributes
      assert_nil Image.new.description
      assert_nil Image.new.caption
      assert_raises NoMethodError do
        Image.new.note
      end
      assert_nil StepImage.new.description
      assert_nil StepImage.new.caption
      assert_nil StepImage.new.note
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
      assert_equal '#<Recipe(recipes(/:id)) id: 2 title: "Pizza" description: "Delicious">', recipe.inspect
      recipe = Recipe.new
      assert_equal '#<Recipe(recipes(/:id)) id: nil >', recipe.inspect
      user = Recipe.new.build_user
      assert_equal '#<User(users/:uuid) id: nil >', user.inspect
      group = Recipe.new.groups.build
      assert_equal '#<Group(recipes/:recipe_id/groups/(:id)) id: nil recipe_id: nil>', group.inspect
    end

    def test_rejecting_wrong_number_of_args
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
