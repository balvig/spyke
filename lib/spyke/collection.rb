module Spyke
  class Collection < ::Array
    attr_reader :metadata

    def initialize(elements, metadata = {})
      super(elements)
      @metadata = metadata
    end
  end
end
