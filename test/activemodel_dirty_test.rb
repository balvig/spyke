require 'test_helper'

module Spyke
  class ActiveModelDirtyTest < MiniTest::Test
    def test_attributes_instance_var_compatibility
      recipe = RecipeWithDirty.new(title: 'Cheeseburger')

      # If @attributes is set on recipe ActiveModel::Dirty will crash
      assert_equal false, recipe.attribute_changed_in_place?(:title)
    end
  end
end
