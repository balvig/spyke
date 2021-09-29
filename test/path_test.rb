require 'test_helper'

module Spyke
  class PathTest < MiniTest::Test
    def test_collection_path
      assert_equal '/recipes', Path.new('/recipes/(:id)').to_s
    end

    def test_resource_path
      assert_equal '/recipes/2', Path.new('/recipes/(:id)', id: 2).to_s
    end

    def test_nested_collection_path
      path = Path.new('/users/:user_id/recipes/(:id)', user_id: 1, status: 'published')
      assert_equal [:user_id, :id], path.variables
      assert_equal '/users/1/recipes', path.to_s
    end

    def test_nested_resource_path
      assert_equal '/users/1/recipes/2', Path.new('/users/:user_id/recipes/:id', user_id: 1, id: 2).to_s
    end

    def test_required_variables
      assert_raises InvalidPathError, 'Missing required variables: user_id in /users/:user_id/recipes/(:id)' do
        Path.new('/users/:user_id/recipes/(:id)', id: 2).to_s
      end
    end

    def test_mix_of_required_and_unrequired_variables
      assert_raises InvalidPathError, 'Missing required variables: part2, part4' do
        Path.new('/1/profiles(/:part1)/:part2(/:part3)/:part4.xml').to_s
      end
    end

    def test_present_optional_param_with_extension
      assert_equal '/1/profiles/2.json', Path.new('/1/profiles(/:id).json', id: 2).to_s
    end

    def test_missing_optional_variables_with_extension
      assert_equal '/1/profiles.json', Path.new('/1/profiles(/:id).json').to_s
    end

    def test_multiple_missing_optional_variables_with_extension
      assert_equal '/1/profiles.xml', Path.new('/1/profiles(/:id1)(/:id2)(/:id3)(/:id4).xml').to_s
    end

    def test_mixture_of_optional_variables_and_required_variables_with_extension
      assert_equal '/1/profiles/other/2.xml', Path.new('/1/profiles(/:part1)/:part2(/:part3)/:id.xml', part2: 'other', id: 2).to_s
    end
  end
end
