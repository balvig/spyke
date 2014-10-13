module Spike
  class Scope

    attr_reader :klass, :params

    def initialize(klass)
      @klass = klass
      @params = {}
    end

    def where(params)
      @params.merge!(params)
      self
    end

    def find(id)
      response = klass.api.get(klass.resource_path(id))
      reset_params!
      klass.new response.body
    end

    def all
      url = "#{klass.collection_path}#{to_query}"
      reset_params!
      response = klass.api.get(url)
      return [] unless response.body
      response.body.map do |record|
        klass.new(record)
      end
    end

    def to_query
      "?#{@params.to_query}" if @params.any?
    end

    private

      def reset_params!
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
