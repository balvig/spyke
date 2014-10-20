require 'test_helper'

module Spike
  class AssociationsTest < MiniTest::Test

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

    def test_build_association
      group = Recipe.new(id: 1).groups.build
      assert_equal 1, group.recipe_id
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

  end
end
