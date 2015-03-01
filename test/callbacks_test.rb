require 'test_helper'

module Spyke
  class CallbacksTest < MiniTest::Test
    def setup
      stub_request(:any, /.*/)
    end

    def test_before_create
      Recipe.any_instance.expects(:before_create_callback)
      Recipe.create
    end

    def test_before_save
      Recipe.any_instance.expects(:before_save_callback)
      Recipe.create
    end

    def test_before_update
      Recipe.any_instance.expects(:before_save_callback)
      Recipe.any_instance.expects(:before_update_callback)
      Recipe.new(id: 1).save
    end
  end
end
