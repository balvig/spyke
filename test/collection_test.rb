require 'test_helper'

Spike::Request.connection =
  Faraday.new(url: 'http://sushi.com') do |faraday|
    faraday.response  :json
    faraday.adapter   Faraday.default_adapter  # make requests with Net::HTTP
  end

class Recipe
  include Spike::Base

  def self.published
    where(status: 'published')
  end
end

module Spike
  class CollectionTest < MiniTest::Test
    def test_all
      stub_request(:get, 'http://sushi.com/recipes').to_return_json(data: [{ id: 1, title: 'Sushi' }, { id: 2, title: 'Nigiri' }], metadata: 'meta')

      recipes = Recipe.all

      assert_equal %w{ Sushi Nigiri }, recipes.map(&:title)
      assert_equal [1, 2], recipes.map(&:id)
      assert_equal 'meta', recipes.metadata
    end

    def test_chainable_where
      endpoint = stub_request(:get, 'http://sushi.com/recipes?status=published&per_page=3')

      Recipe.where(status: 'published').where(per_page: 3).to_a

      assert_requested endpoint
    end

    def test_chainable_class_method
      endpoint = stub_request(:get, 'http://sushi.com/recipes?status=published&per_page=3')

      Recipe.where(per_page: 3).published.to_a

      assert_requested endpoint
    end

    def test_prepended_chainable_class_method
      endpoint = stub_request(:get, 'http://sushi.com/recipes?status=published&per_page=3')

      Recipe.published.where(per_page: 3).to_a

      assert_requested endpoint
    end

    def test_scope_doesnt_get_stuck
      endpoint_1 = stub_request(:get, 'http://sushi.com/recipes?per_page=3&status=published')
      endpoint_2 = stub_request(:get, 'http://sushi.com/recipes?status=published')

      Recipe.where(status: 'published').where(per_page: 3).to_a
      Recipe.where(status: 'published').to_a
      assert_requested endpoint_1
      assert_requested endpoint_2
    end

    def test_only_called_once
      endpoint = stub_request(:get, 'http://sushi.com/recipes?status=published&per_page=3')

      recipes = Recipe.published.where(per_page: 3)
      recipes.any?
      recipes.to_a
      assert_requested endpoint
    end
  end
end
