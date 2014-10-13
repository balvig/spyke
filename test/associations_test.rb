require 'test_helper'

class Recipe
  include Spike::Base
  has_many :groups
  has_one :image

  def ingredients
    groups.first.ingredients
  end
end

class Image
  include Spike::Base
end

class Group
  include Spike::Base
  has_many :ingredients
end

class Ingredient
  include Spike::Base
end

module Spike
  class AssociationsTest < MiniTest::Test
    def test_embedded_associations
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(data: { groups: [{ id: 1, name: 'Fish' }] })

      assert_equal %i{ groups image }, Recipe.associations.keys
      recipe = Recipe.find(1)

      assert_equal %w{ Fish }, recipe.groups.map(&:name)
    end

    def test_nested_associtations
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

    def test_build
      group = Recipe.new(id: 1).groups.build
      assert_equal 1, group.recipe_id
    end

  end
end
