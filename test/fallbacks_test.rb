require 'test_helper'

module Spyke
  class FallbacksTest < MiniTest::Test
    def setup
      stub_request(:get, "http://sushi.com/recipes/1").to_timeout
      stub_request(:get, "http://sushi.com/recipes?published=true").to_timeout
    end

    def test_find_without_fallback
      assert_raises ConnectionError do
        Recipe.find(1)
      end
    end

    def test_find_with_default_fallback
      assert_raises ResourceNotFound do
        Recipe.with_fallback.find(1)
      end
    end

    def test_find_with_custom_fallback
      dummy_recipe = Recipe.new(title: "Dummy Recipe")

      result = Recipe.with_fallback(dummy_recipe).find(1)

      assert_equal "Dummy Recipe", result.title
    end

    def test_find_one_with_default_fallback
      recipe = Recipe.with_fallback.where(id: 1).find_one

      assert_nil recipe
    end

    def test_find_some_with_default_fallback
      assert_equal [], Recipe.where(published: true).with_fallback.all.to_a
    end

    def test_find_some_with_custom_fallback
      dummy_result = [Recipe.new(title: "Dummy Recipe")]

      result = Recipe.where(published: true).with_fallback(dummy_result).all

      assert_equal "Dummy Recipe", result.first.title
    end
  end
end
