require 'test_helper'

module Spike
  class AssociationsTest < MiniTest::Test
    def test_association_independence
      assert_kind_of Associations::HasMany, Recipe.new.groups
      assert_raises NoMethodError do
        Recipe.new.recipes
      end
    end

    def test_initializing_with_has_many_association
      group = Group.new(ingredients: [Ingredient.new(title: 'Water'), Ingredient.new(title: 'Flour')])
      assert_equal %w{ Water Flour }, group.ingredients.map(&:title)
      assert_equal({ 'group' => { 'ingredients' => [{ 'title' => 'Water' }, { 'title' => 'Flour' }] } }, group.to_params)
    end

    def test_initializing_with_has_one_association
      recipe = Recipe.new(image: Image.new(url: 'bob.jpg'))
      assert_equal 'bob.jpg', recipe.image.url
    end

    def test_initializing_with_blank_has_one_association
      recipe = Recipe.new(image: Image.new)
      assert_kind_of Image, recipe.image
    end

    def test_embedded_associations
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(data: { groups: [{ id: 1, name: 'Fish' }] })

      recipe = Recipe.find(1)

      assert_equal %w{ Fish }, recipe.groups.map(&:name)
    end

    def test_nested_embedded_associtations
      json = { data: { groups: [{ ingredients: [{ id: 1, name: 'Fish' }] }, { ingredients: [] }] } }
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(json)

      recipe = Recipe.find(1)

      assert_equal %w{ Fish }, recipe.ingredients.map(&:name)
    end

    def test_singular_associtations
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(data: { image: { url: 'bob.jpg' } })

      recipe = Recipe.find(1)

      assert_equal 'bob.jpg', recipe.image.url
    end

    def test_unloaded_has_many_association
      endpoint = stub_request(:get, 'http://sushi.com/recipes/1/groups?public=true').to_return_json(data: [{ id: 1 }])

      groups = Recipe.new(id: 1).groups.where(public: true).to_a

      assert_equal 1, groups.first.id
      assert_requested endpoint
    end

    def test_unloaded_has_one_association
      endpoint = stub_request(:get, 'http://sushi.com/recipes/1/image').to_return_json(data: { url: 'bob.jpg' })

      image = Recipe.new(id: 1).image

      assert_equal 'bob.jpg', image.url
      assert_requested endpoint
    end

    def test_array_like_behavior
      stub_request(:get, 'http://sushi.com/recipes/1/groups').to_return_json(data: [{ name: 'Fish' }, { name: 'Fruit' }, { name: 'Bread' }])

      recipe = Recipe.new(id: 1)

      assert_equal %w{ Fish Fruit }, recipe.groups[0..1].map(&:name)
      assert_equal 'Bread', recipe.groups.last.name
      assert_equal 'Fish', recipe.groups.first.name
    end

    def test_nil_has_one_association
      stub_request(:get, 'http://sushi.com/recipes/1/image')

      image = Recipe.new(id: 1).image

      assert_nil image
    end

    def test_unloaded_belongs_to_association
      endpoint = stub_request(:get, 'http://sushi.com/users/1')

      recipe = Recipe.new(user_id: 1)
      recipe.user

      assert_requested endpoint
    end

    def test_scopes_on_assocations
      endpoint = stub_request(:get, 'http://sushi.com/users/1/recipes?page=2')

      User.new(id: 1).recipes.page(2).to_a

      assert_requested endpoint
    end

    def test_build_has_many_association
      recipe = Recipe.new(id: 1)
      recipe.groups.build
      assert_equal 1, recipe.groups.first.recipe_id
    end

    def test_new_has_many_association
      recipe = Recipe.new(id: 1)
      recipe.groups.new
      assert_equal 1, recipe.groups.first.recipe_id
    end

    def test_deep_build_has_many_association
      recipe = Recipe.new(id: 1)
      recipe.groups.build(ingredients: [Ingredient.new(name: 'Salt')])

      assert_equal %w{ Salt }, recipe.ingredients.map(&:name)
      assert_equal({ 'recipe' => { 'groups' => [{ 'recipe_id' => 1, 'ingredients' => [{ 'name' => 'Salt' }] }] } }, recipe.to_params)
    end

    def test_deep_build_has_many_association_with_scope
      recipe = User.new(id: 1).recipes.published.build

      assert_equal({ 'recipe' => { 'status' => 'published' } }, recipe.to_params)
    end

    def test_build_association_with_ids
      user = User.new(id: 1, recipes: [{ id: 1 }])
      user.recipe_ids = ['', 2]

      assert_equal [2], user.recipes.map(&:id)
      assert_equal({ 'user' => { 'recipes' => [{ 'user_id' => 1, 'id' => 2 }] } }, user.to_params)
    end

    def test_converting_association_to_ids
      stub_request(:get, 'http://sushi.com/users/1/recipes').to_return_json(data: [{ id: 2 }])
      user = User.new(id: 1)
      assert_equal [2], user.recipe_ids
    end

    def test_build_has_one_association
      recipe = Recipe.new(id: 1)
      image = recipe.build_image
      assert_equal 1, image.recipe_id
      assert_equal 1, recipe.image.recipe_id
    end

    def test_custom_class_name
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(data: { background_image: { url: 'bob.jpg' } })

      recipe = Recipe.find(1)

      assert_equal 'bob.jpg', recipe.background_image.url
      assert_equal Image, recipe.background_image.class
    end

    def test_cached_result
      endpoint_1 = stub_request(:get, 'http://sushi.com/recipes/1/groups?per_page=3')
      endpoint_2 = stub_request(:get, 'http://sushi.com/recipes/1/groups')

      recipe = Recipe.new(id: 1)
      groups = recipe.groups.where(per_page: 3)
      groups.any?
      groups.to_a
      assert_requested endpoint_1, times: 1

      recipe.groups.to_a
      assert_requested endpoint_2, times: 1
    end

    def test_custom_uri_template
      endpoint = stub_request(:get, 'http://sushi.com/recipes/1/alternates/recipe')
      Recipe.new(id: 1).alternate
      assert_requested endpoint
    end

    def test_create_association
      endpoint = stub_request(:post, 'http://sushi.com/recipes/1/groups').with(body: { group: { title: 'Topping' } }).to_return_json(data: { title: 'Topping', id: 1, recipe_id: 1 })

      recipe = Recipe.new(id: 1)
      group = recipe.groups.create(title: 'Topping')

      assert_equal 'Topping', group.title
      assert_equal 1, group.id
      assert_equal 'Topping', recipe.groups.last.title
      assert_equal 1, recipe.groups.last.id
      assert_requested endpoint
    end

    def test_create_association_with_no_params
      endpoint = stub_request(:post, 'http://sushi.com/recipes/1/groups').with(body: { group: {} })

      Recipe.new(id: 1).groups.create

      assert_requested endpoint
    end

    def test_create_scoped_association
      endpoint = stub_request(:post, 'http://sushi.com/users/1/recipes').with(body: { recipe: { title: 'Sushi', status: 'published' } })

      User.new(id: 1).recipes.published.create(title: 'Sushi')

      assert_requested endpoint
    end

    def test_save_association
      endpoint = stub_request(:post, 'http://sushi.com/recipes/1/groups').with(body: { group: { title: 'Topping' } }).to_return_json(data: { title: 'Topping', recipe_id: 1 })

      group = Recipe.new(id: 1).groups.build(title: 'Topping')
      group.save

      assert_equal 'Topping', group.title
      assert_requested endpoint
    end

    def test_nested_attributes_has_one
      recipe = Recipe.new(image_attributes: { file: 'bob.jpg' })
      assert_equal 'bob.jpg', recipe.image.file
    end

    def test_nested_attributes_belongs_to
      recipe = Recipe.new(user_attributes: { name: 'Bob' })
      assert_equal 'Bob', recipe.user.name
    end

    def test_nested_attributes_has_many
      recipe = Recipe.new(groups_attributes: [{ title: 'starter' }, { title: 'sauce' }])
      assert_equal %w{ starter sauce }, recipe.groups.map(&:title)
    end

    def test_nested_attributes_overwriting_existing
      recipe = Recipe.new(groups_attributes: [{ title: 'starter' }, { title: 'sauce' }])
      recipe.attributes = { groups_attributes: [{ title: 'flavor' }] }
      assert_equal %w{ starter sauce flavor }, recipe.groups.map(&:title)
    end

    def test_nested_attributes_merging_with_existing
      recipe = Recipe.new(groups_attributes: [{ id: 1, title: 'starter', description: 'nice' }, { id: 2, title: 'sauce', description: 'spicy' }])
      recipe.attributes = { groups_attributes: [{ 'id' => '2', 'title' => 'flavor' }] }
      assert_equal %w{ starter flavor }, recipe.groups.map(&:title)
      assert_equal %w{ nice spicy }, recipe.groups.map(&:description)
    end

    def test_nested_attributes_has_many_using_hash_syntax
      recipe = Recipe.new(groups_attributes: { '0' => { title: 'starter' }, '1' => { title: 'sauce' } })
      assert_equal %w{ starter sauce }, recipe.groups.map(&:title)
    end

    def test_nested_nested_attributes
      recipe = Recipe.new(groups_attributes: { '0' => { ingredients_attributes: { '0' => { name: 'Salt' } } } })
      assert_equal %w{ Salt }, recipe.ingredients.map(&:name)
    end

    def test_reflect_on_association
      assert_equal Group, Recipe.reflect_on_association(:group).klass
      skip 'wishlisted'
      assert_equal Recipe, Recipe.reflect_on_association(:alternate).klass
    end

    def test_embed_only_singular_associations
      assert_nil Recipe.new.background_image
      assert_equal 'photo.jpg', Recipe.new(background_image: { url: 'photo.jpg' }).background_image.url
    end

    def test_embed_only_plural_associations
      assert_equal [], Group.new.ingredients.to_a
      assert_equal [1], Group.new(ingredients: [{ id: 1 }]).ingredients.map(&:id)
    end
  end
end
