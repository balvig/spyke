module Spike
  class Scope

    attr_reader :klass, :params

    def initialize(klass)
      @klass = klass
      @params = {}
    end

    def where(params = {})
      @params.merge!(params)
      self
    end

    def find(id)
      scoping { klass.get_resource(id) }
    end

    def all
      scoping { klass.get_collection }
    end

    def to_query
      "?#{@params.to_query}" if @params.any?
    end

    private

      def scoping
        yield
      ensure
        @params = {}
      end

      def method_missing(name, *args, &block)
        if klass.respond_to?(name)
          klass.send(name)
        else
          super
        end
      end
  end
end
