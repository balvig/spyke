require 'test_helper'

module Spyke
  class RelationTest < MiniTest::Test
    def test_all
      stub_request(:get, 'http://sushi.com/recipes').to_return_json(result: [{ id: 1, title: 'Sushi' }, { id: 2, title: 'Nigiri' }], metadata: 'meta')

      recipes = Recipe.all

      assert_equal %w{ Sushi Nigiri }, recipes.map(&:title)
      assert_equal [1, 2], recipes.map(&:id)
      assert_equal 'meta', recipes.metadata
    end

    def test_scope_independence
      endpoint = stub_request(:get, 'http://sushi.com/recipes?query=chicken')
      wrong_endpoint = stub_request(:get, 'http://sushi.com/recipes?query=chicken&page=1')

      search = Search.new('chicken')
      variant = search.recipes.where(page: 1)
      original = search.recipes

      refute_same variant, original

      original.to_a

      assert_not_requested wrong_endpoint
      assert_requested endpoint, times: 1
    end

    def test_scope_not_firing_twice_for_duplicate_scope
      endpoint = stub_request(:get, 'http://sushi.com/recipes?query=chicken')

      search = Search.new('chicken')
      search.recipes.page.to_a
      search.suggestions

      assert_requested endpoint, times: 1
    end

    def test_scope_with_find
      endpoint = stub_request(:get, 'http://sushi.com/recipes/1?status=published').to_return_json(result: { id: 1 })

      Recipe.where(status: 'published').find(1)

      assert_requested endpoint
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

    def test_scope_class_method
      endpoint = stub_request(:get, 'http://sushi.com/recipes?status=published&page=3')

      Recipe.published.page(3).to_a
      assert_requested endpoint
    end

    def test_scope_class_method_doesnt_get_overridden
      recipe_endpoint = stub_request(:get, 'http://sushi.com/recipes?approved=true')
      comment_endpoint = stub_request(:get, 'http://sushi.com/comments?comment_approved=true')

      Recipe.approved.to_a
      assert_requested recipe_endpoint
      Comment.approved.to_a
      assert_requested comment_endpoint
    end

    def test_scope_doesnt_get_stuck
      endpoint_1 = stub_request(:get, 'http://sushi.com/recipes?per_page=3&status=published')
      endpoint_2 = stub_request(:get, 'http://sushi.com/recipes?status=published')

      Recipe.where(status: 'published').where(per_page: 3).to_a
      Recipe.where(status: 'published').to_a
      assert_requested endpoint_1
      assert_requested endpoint_2
    end

    def test_create_scoped
      endpoint = stub_request(:post, 'http://sushi.com/recipes').with(body: { recipe: { title: 'Sushi', status: 'published' } })

      Recipe.published.create(title: 'Sushi')

      assert_requested endpoint
    end

    def test_cached_result
      endpoint_1 = stub_request(:get, 'http://sushi.com/recipes?status=published&per_page=3')
      endpoint_2 = stub_request(:get, 'http://sushi.com/recipes?status=published')

      recipes = Recipe.published.where(per_page: 3)
      recipes.any?
      recipes.to_a
      assert_requested endpoint_1, times: 1
      Recipe.published.to_a
      assert_requested endpoint_2, times: 1
    end
  end
end
