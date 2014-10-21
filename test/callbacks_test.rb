require 'test_helper'

module Spike
  class CallbacksTest < MiniTest::Test

    def test_before_create
      skip
      Recipe.any_instance.expects(:before_create_callback)
      Recipe.create
    end

    def test_before_update

    end

    def test_before_save

    end

  end
end
