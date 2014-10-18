module Spike
  class Path < Pathname
    def initialize(*args)
      super File.join(args)
    end
  end
end
