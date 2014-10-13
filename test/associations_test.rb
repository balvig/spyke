require 'test_helper'

Spike::Request.connection =
  Faraday.new(url: 'http://sushi.com') do |faraday|
    faraday.response  :json
    faraday.adapter   Faraday.default_adapter  # make requests with Net::HTTP
  end


class Recipe
  include Spike::Base
  has_many :ingredient_groups
  has_one :image

  def ingredients
    ingredient_groups.first.ingredients
  end
end

class Image
  include Spike::Base
end

class IngredientGroup
  include Spike::Base
  has_many :ingredients
end

class Ingredient
  include Spike::Base
end

module Spike
  class AssociationsTest < MiniTest::Test
    def test_associations
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(data: { ingredient_groups: [{ id: 1, name: 'Fish' }] })

      assert_equal %i{ ingredient_groups image }, Recipe.associations
      recipe = Recipe.find(1)

      assert_equal %w{ Fish }, recipe.ingredient_groups.map(&:name)
    end

    def test_nested_associtations
      json = { data: { ingredient_groups: [{ ingredients: [{ id: 1, name: 'Fish' }] }, { ingredients: [] }] } }
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
      skip
      endpoint = stub_request(:get, 'http://sushi.com/recipes/1/ingredient_groups')

      recipe = Recipe.new(id: 1).ingredient_groups.to_a

      assert_requested(endpoint)
    end

  end
end
