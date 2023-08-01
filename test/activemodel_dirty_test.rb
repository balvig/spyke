require 'test_helper'

module Spyke
  class ActiveModelDirtyTest < Minitest::Test
    def test_attributes_instance_var_compatibility
      recipe = RecipeWithDirty.new(title: 'Cheeseburger')

      # If @attributes is set on recipe ActiveModel::Dirty will crash
      assert_equal({}, recipe.changes)
    end
  end
end
