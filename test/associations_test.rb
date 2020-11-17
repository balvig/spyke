require 'test_helper'
require 'action_controller/metal/strong_parameters'

module Spyke
  class AssociationsTest < MiniTest::Test
    def test_association_independence
      assert_kind_of Associations::HasMany, Recipe.new.groups
      assert_raises NoMethodError do
        Recipe.new.recipes
      end
    end

    def test_association_get_ingredients_with_index
      group = Group.new(ingredients: [Ingredient.new(name: 'Water'), Ingredient.new(name: 'Flour')])
      assert_equal [['Water', 0], ['Flour', 1]], group.ingredients.each.with_index.map {|ingredient, idx| [ingredient.name, idx]}
    end

    def test_initializing_with_has_many_association
      group = Group.new(ingredients: [Ingredient.new(name: 'Water'), Ingredient.new(name: 'Flour')])
      assert_equal %w{ Water Flour }, group.ingredients.map(&:name)
      assert_equal({ 'group' => { 'ingredients' => [{ 'name' => 'Water' }, { 'name' => 'Flour' }] } }, group.to_params)
    end

    def test_initializing_with_has_one_association
      recipe = Recipe.new(image: Image.new(url: 'bob.jpg'))
      assert_equal 'bob.jpg', recipe.image.url
    end

    def test_initializing_with_blank_has_one_association
      recipe = Recipe.new(image: Image.new)
      assert_kind_of Image, recipe.image
    end

    def test_initializing_using_strong_params
      ingredient = Ingredient.new(strong_params(name: 'Flour'))
      assert_equal 'Flour', ingredient.name
    end

    def test_embedded_associations
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(result: { groups: [{ id: 1, name: 'Fish' }] })

      recipe = Recipe.find(1)

      assert_equal %w{ Fish }, recipe.groups.map(&:name)
    end

    def test_nested_embedded_associations
      json = { result: { groups: [{ ingredients: [{ id: 1, name: 'Fish' }] }, { ingredients: [] }] } }
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(json)

      recipe = Recipe.find(1)

      assert_equal %w{ Fish }, recipe.ingredients.map(&:name)
    end

    def test_singular_associations
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(result: { image: { url: 'bob.jpg' } })

      recipe = Recipe.find(1)

      assert_equal 'bob.jpg', recipe.image.url
    end

    def test_unloaded_has_many_association
      endpoint = stub_request(:get, 'http://sushi.com/recipes/1/groups?public=true').to_return_json(result: [{ id: 1 }])

      groups = Recipe.new(id: 1).groups.where(public: true).to_a

      assert_equal 1, groups.first.id
      assert_requested endpoint
    end

    def test_find_on_has_many_association
      endpoint = stub_request(:get, 'http://sushi.com/recipes/1/groups/1').to_return_json(result: { id: 1 })

      group = Recipe.new(id: 1).groups.find(1)

      assert_requested endpoint
      assert_equal 1, group.id
    end

    def test_unloaded_has_one_association
      endpoint = stub_request(:get, 'http://sushi.com/recipes/1/image').to_return_json(result: { url: 'bob.jpg' })

      image = Recipe.new(id: 1).image

      assert_equal 'bob.jpg', image.url
      assert_requested endpoint
    end

    def test_array_like_behavior
      stub_request(:get, 'http://sushi.com/recipes/1/groups').to_return_json(result: [{ name: 'Fish' }, { name: 'Fruit' }, { name: 'Bread' }])

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

    def test_build_belongs_to_association
      recipe = Recipe.new(id: 1)
      recipe.build_user(name: 'Alice')
      assert_equal recipe.user.name, 'Alice'
    end

    def test_build_has_one_association
      recipe = Recipe.new(id: 1)
      image = recipe.build_image
      assert_equal 1, image.recipe_id
      assert_equal 1, recipe.image.recipe_id
    end

    def test_multiple_builds
      recipe = Recipe.new
      recipe.groups.build(name: 'Condiments')
      recipe.groups.build(name: 'Tools')
      assert_equal %w{ Condiments Tools }, recipe.groups.map(&:name)
    end

    def test_new_has_many_association
      recipe = Recipe.new(id: 1)
      recipe.groups.new
      assert_equal 1, recipe.groups.first.recipe_id
    end

    def test_destroy_has_many_association
      endpoint = stub_request(:delete, 'http://sushi.com/recipes/1/groups/2')
      recipe = Recipe.new(id: 1)
      recipe.groups.destroy(2)
      assert_requested endpoint
    end

    def test_changing_attributes_directly_after_build_on_has_many_association
      recipe = Recipe.new(id: 1)
      recipe.groups.build(name: 'Dessert')
      recipe.groups.first.name = 'Starter'

      assert_equal 'Starter', recipe.groups.first.name
      assert_equal({ 'recipe' => { 'groups' => [{ 'recipe_id' => 1, 'name' => 'Starter' }] } }, recipe.to_params)
    end

    def test_changing_attributes_on_reference_after_build_on_has_many_association
      recipe = Recipe.new(id: 1)
      group = recipe.groups.build(name: 'Dessert')
      group.name = 'Starter'

      assert_equal 'Starter', recipe.groups.first.name
      assert_equal({ 'recipe' => { 'groups' => [{ 'recipe_id' => 1, 'name' => 'Starter' }] } }, recipe.to_params)
    end

    def test_deep_build_has_many_association
      recipe = Recipe.new(id: 1)
      recipe.groups.build(ingredients: [Ingredient.new(name: 'Salt')])

      assert_equal %w{ Salt }, recipe.ingredients.map(&:name)
      assert_equal({ 'recipe' => { 'groups' => [{ 'recipe_id' => 1, 'ingredients' => [{ 'name' => 'Salt' }] }] } }, recipe.to_params)
    end

    def test_sequential_deep_build_has_many_association
      recipe = Recipe.new(id: 1)
      recipe.groups.build
      recipe.groups.first.ingredients.build(name: 'Salt')

      assert_equal %w{ Salt }, recipe.ingredients.map(&:name)
      assert_equal({ 'recipe' => { 'groups' => [{ 'recipe_id' => 1, 'ingredients' => [{ 'group_id' => nil, 'name' => 'Salt' }] }] } }, recipe.to_params)
      assert_equal({ 'group' => { 'ingredients' => [{ 'group_id' => nil, 'name' => 'Salt' }] } }, recipe.groups.first.to_params)
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
      stub_request(:get, 'http://sushi.com/users/1/recipes').to_return_json(result: [{ id: 2 }])
      user = User.new(id: 1)
      assert_equal [2], user.recipe_ids
    end

    def test_custom_class_name
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(result: { background_image: { url: 'bob.jpg' } })

      recipe = Recipe.find(1)

      assert_equal 'bob.jpg', recipe.background_image.url
      assert_equal Image, recipe.background_image.class
    end

    def test_cached_result_for_associations
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

    def test_path_inferred_from_name
      endpoint = stub_request(:get, 'http://sushi.com/recipes/1/gallery_images')
      Recipe.new(id: 1).gallery_images.to_a
      assert_requested endpoint
    end

    def test_create_association
      endpoint = stub_request(:post, 'http://sushi.com/recipes/1/groups').with(body: { group: { title: 'Topping' } }).to_return_json(result: { title: 'Topping', id: 1, recipe_id: 1 })

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
      endpoint = stub_request(:post, 'http://sushi.com/recipes/1/groups').with(body: { group: { title: 'Topping' } }).to_return_json(result: { title: 'Topping', recipe_id: 1 })

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

    def test_nested_attributes_has_one_using_strong_params
      recipe = Recipe.new(image_attributes: strong_params(file: 'bob.jpg').permit!)
      assert_equal 'bob.jpg', recipe.image.file
    end

    def test_nested_attributes_belongs_to_using_strong_params
      recipe = Recipe.new(user_attributes: strong_params({ name: 'Bob' }).permit!)
      assert_equal 'Bob', recipe.user.name
    end

    def test_nested_attributes_has_many_using_strong_params
      params = strong_params(groups_attributes: [strong_params(title: 'starter').permit!, strong_params(title: 'sauce').permit!]).permit!
      recipe = Recipe.new(params)
      assert_equal %w{ starter sauce }, recipe.groups.map(&:title)
    end

    def test_nested_attributes_replacing_existing_when_no_ids_present
      recipe = Recipe.new(groups_attributes: [{ title: 'starter' }, { title: 'sauce' }])
      recipe.attributes = { groups_attributes: [{ title: 'flavor' }] }
      assert_equal %w{ flavor }, recipe.groups.map(&:title)
    end

    def test_nested_attributes_merging_with_existing_when_ids_present
      recipe = Recipe.new(groups_attributes: [{ id: 1, title: 'starter', description: 'nice' }, { id: 2, title: 'sauce', description: 'spicy' }])
      recipe.attributes = { groups_attributes: [{ 'id' => '2', 'title' => 'flavor' }, { 'title' => 'spices', 'description' => 'lovely' }, { 'title' => 'sweetener', 'description' => 'sweet' }] }
      assert_equal %w{ starter flavor spices sweetener }, recipe.groups.map(&:title)
      assert_equal %w{ nice spicy lovely sweet }, recipe.groups.map(&:description)
    end

    def test_nested_attributes_appending_to_existing_when_ids_present
      recipe = Recipe.new(groups_attributes: [{ id: 1, title: 'starter' }, { id: 2, title: 'sauce' }])
      recipe.attributes = { groups_attributes: [{ title: 'flavor' }] }
      assert_equal %w{ starter sauce flavor }, recipe.groups.map(&:title)
    end

    def test_nested_attributes_has_many_using_hash_syntax
      recipe = Recipe.new(groups_attributes: { '0' => { title: 'starter' }, '1' => { title: 'sauce' } })
      assert_equal %w{ starter sauce }, recipe.groups.map(&:title)
    end

    def test_nested_attributes_has_many_using_strong_params_with_hash_syntax
      params = strong_params(
        groups_attributes: strong_params(
          '0' => strong_params(title: 'starter').permit!,
          '1' => strong_params(title: 'sauce').permit!,
        ).permit!
      ).permit!
      recipe = Recipe.new(params)
      assert_equal %w{ starter sauce }, recipe.groups.map(&:title)
    end

    def test_deeply_nested_attributes_has_many_using_array_syntax
      params = { groups_attributes: [{ id: 1, ingredients_attributes: [{ id: 1, name: 'Salt' }, { id: 2, name: 'Pepper' } ]}] }
      recipe = Recipe.new(params)
      assert_equal %w{ Salt Pepper }, recipe.ingredients.map(&:name)
      recipe.attributes = params
      assert_equal %w{ Salt Pepper }, recipe.ingredients.map(&:name)
    end

    def test_deeply_nested_attributes_has_many_using_hash_syntax
      params = { groups_attributes: { '0' => { id: 1, ingredients_attributes: { '0' => { id: 1, name: 'Salt' }, '1' => { id: 2, name: 'Pepper' } } } } }
      recipe = Recipe.new(params)
      assert_equal %w{ Salt Pepper }, recipe.ingredients.map(&:name)
      recipe.attributes = params
      assert_equal %w{ Salt Pepper }, recipe.ingredients.map(&:name)
    end

    def test_deeply_nested_attributes_has_many_with_blank_ids_using_array_syntax
      params = { groups_attributes: [{ ingredients_attributes: [{ name: 'Salt' }, { name: 'Pepper' }]}] }
      recipe = Recipe.new(params)
      assert_equal %w{ Salt Pepper }, recipe.ingredients.map(&:name)
      recipe.attributes = params
      assert_equal %w{ Salt Pepper }, recipe.ingredients.map(&:name)
    end

    def test_deeply_nested_attributes_has_many_with_blank_ids_using_hash_syntax
      params = { groups_attributes: { '0' => { ingredients_attributes: { '0' => { id: '', name: 'Salt' }, '1' => { id: '', name: 'Pepper' } } } } }
      recipe = Recipe.new(params)
      assert_equal %w{ Salt Pepper }, recipe.ingredients.map(&:name)
      recipe.attributes = params
      assert_equal %w{ Salt Pepper }, recipe.ingredients.map(&:name)
    end

    def test_deeply_nested_attributes_has_many_using_strong_params_with_array_syntax
      params = strong_params(
        groups_attributes: [
          strong_params(
            ingredients_attributes: [
              strong_params(id: '', name: 'Salt').permit!,
              strong_params(id: '', name: 'Pepper').permit!,
            ]
          ).permit!
        ]
      ).permit!
      recipe = Recipe.new(params)
      assert_equal %w{ Salt Pepper }, recipe.ingredients.map(&:name)
      recipe.attributes = params
      assert_equal %w{ Salt Pepper }, recipe.ingredients.map(&:name)
    end

    def test_deeply_nested_attributes_has_many_using_strong_params_with_hash_syntax
      params = strong_params(
        groups_attributes: strong_params(
          '0' => strong_params(
            ingredients_attributes: strong_params(
              '0' => strong_params(id: '', name: 'Salt').permit!,
              '1' => strong_params(id: '', name: 'Pepper').permit!,
            ).permit!
          ).permit!
        ).permit!
      ).permit!
      recipe = Recipe.new(params)
      assert_equal %w{ Salt Pepper }, recipe.ingredients.map(&:name)
      recipe.attributes = params
      assert_equal %w{ Salt Pepper }, recipe.ingredients.map(&:name)
    end

    def test_reflect_on_association
      assert_equal Group, Recipe.reflect_on_association(:group).klass
      assert_equal Cookbook::Like, Cookbook::Tip.reflect_on_association(:like).klass
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

    def test_class_methods_for_associations
      recipe = Recipe.new
      recipe.groups.build_default

      assert_equal({ 'recipe' => { 'groups' => [{ 'recipe_id' => nil, 'name' => 'Condiments', 'ingredients' => [{ 'group_id' => nil, 'name' => 'Salt' }] }, { 'recipe_id' => nil, 'name' => 'Tools', 'ingredients' => [{ 'group_id' => nil, 'name' => 'Spoon' }] }] } }, recipe.to_params)
      assert_equal %w{ Condiments Tools }, recipe.groups.map(&:name)
      assert_equal %w{ Salt Spoon }, recipe.ingredients.map(&:name)
    end

    def test_not_caching_result_with_different_params
      endpoint_1 = stub_request(:get, 'http://sushi.com/recipes/1/groups/1').to_return_json(result: { id: 1 })
      endpoint_2 = stub_request(:get, 'http://sushi.com/recipes/1/groups/2').to_return_json(result: { id: 2 })

      recipe = Recipe.new(id: 1)
      recipe.groups.find(1)
      recipe.groups.find(2)

      assert_requested endpoint_1, times: 1
      assert_requested endpoint_2, times: 1
    end

    def test_namespaced_model
      tip_endpoint = stub_request(:get, 'http://sushi.com/tips/1').to_return_json(result: { id: 1 })
      nested_likes_endpoint = stub_request(:get, 'http://sushi.com/tips/1/likes')
      likes_endpoint = stub_request(:get, 'http://sushi.com/likes')

      Cookbook::Tip.new(id: 1).likes.first
      Cookbook::Like.new(tip_id: 1).tip
      Cookbook::Like.all.to_a

      assert_requested tip_endpoint
      assert_requested nested_likes_endpoint
      assert_requested likes_endpoint
    end

    def test_namespaced_foreign_key
      like = Cookbook::Tip.new(id: 1).likes.build
      assert_equal 1, like.tip_id
    end

    def test_namespaced_association_class_auto_detect
      favorite = Cookbook::Tip.new.favorites.build
      assert_equal Cookbook::Favorite, favorite.class
    end

    def test_specifying_class_outside_of_namespace
      photo = Cookbook::Tip.new.photos.build
      assert_equal Photo, photo.class
    end

    def test_raising_exception_if_class_not_found
      assert_raises NameError do
        Cookbook::Tip.new.votes
      end
    end

    def test_custom_primary_key_for_belongs_to
      comment_endpoint = stub_request(:get, 'http://sushi.com/comments/1').to_return_json(result: { user_id: 1 })
      user_endpoint = stub_request(:get, 'http://sushi.com/users/1').to_return_json(result: { id: 2 })
      user = Comment.find(1).user
      assert_equal 2, user.id
      assert_requested comment_endpoint
      assert_requested user_endpoint
    end

    def test_return_nil_for_missing_id_for_belongs_to
      recipe = Recipe.new(id: 1, user_id: nil)
      assert_nil recipe.user
    end

    def test_custom_primary_key_for_has_many
      stub_request(:get, 'http://sushi.com/comments/1').to_return_json(result: { users: [{ id: 1 }] })
      comment = Comment.find(1)
      assert_equal 1, comment.users.first.id
    end

    def test_custom_primary_key_with_nested_attributes
      comment = Comment.new(users_attributes: [{ uuid: 1, name: "user_1" }])
      comment.attributes = { users_attributes: [{ uuid: 1, name: "user_1_new_name"}] }
      assert_equal %w{ user_1_new_name }, comment.users.map(&:name)
      assert_equal [1], comment.users.map(&:id)
    end

    private

      def strong_params(params)
        ActionController::Parameters.new(params)
      end
  end
end
