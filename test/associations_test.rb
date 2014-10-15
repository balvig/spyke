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

    def test_unloaded_associations
      endpoint = stub_request(:get, 'http://sushi.com/recipes/1/groups?public=true').to_return_json(data: [{ id: 1 }])

      groups = Recipe.new(id: 1).groups.where(public: true).to_a

      assert_equal 1, groups.first.id
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

  end
end
