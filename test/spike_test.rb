require 'test_helper'

class Recipe #< Spike::Base
  include Spike::Base
  has_many :ingredient_groups
  has_one :image

  def self.published
    where(status: 'published')
  end

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
  class SpikeTest < MiniTest::Test
    def test_basic_find
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(id: 1, title: 'Sushi')

      recipe = Recipe.find(1)

      assert_equal 1, recipe.id
      assert_equal 'Sushi', recipe.title
    end

    def test_basic_all
      stub_request(:get, 'http://sushi.com/recipes').to_return_json([{ id: 1, title: 'Sushi' }, { id: 2, title: 'Nigiri' }])

      recipes = Recipe.all

      assert_equal %w{ Sushi Nigiri }, recipes.map(&:title)
      assert_equal [1, 2], recipes.map(&:id)
    end

    def test_associations
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(ingredient_groups: [{ id: 1, name: 'Fish' }])

      assert_equal %i{ ingredient_groups image }, Recipe.associations
      recipe = Recipe.find(1)

      assert_equal %w{ Fish }, recipe.ingredient_groups.map(&:name)
    end

    def test_nested_associtations
      json = { ingredient_groups: [{ ingredients: [{ id: 1, name: 'Fish' }] }, { ingredients: [] }] }
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(json)

      recipe = Recipe.find(1)

      assert_equal %w{ Fish }, recipe.ingredients.map(&:name)
    end

    def test_singular_associtations
      stub_request(:get, 'http://sushi.com/recipes/1').to_return_json(image: { url: 'bob.jpg' })

      recipe = Recipe.find(1)

      assert_equal 'bob.jpg', recipe.image.url
    end

    def test_chainable_where
      endpoint = stub_request(:get, 'http://sushi.com/recipes?status=published&per_page=3')

      Recipe.where(status: 'published').where(per_page: 3).all

      assert_requested endpoint
    end

    def test_chainable_class_method
      endpoint = stub_request(:get, 'http://sushi.com/recipes?status=published&per_page=3')

      Recipe.where(per_page: 3).published.all

      assert_requested endpoint
    end

  end
end
