require 'spike/collection'
require 'spike/request'

module Spike
  class Relation
    include Enumerable

    attr_reader :klass, :params
    delegate :to_ary, :metadata, to: :find_some

    def initialize(klass)
      @klass, @params = klass, {}
    end

    def where(params = {})
      @params.merge!(params)
      self
    end

    def find(id)
      where id: strip_slug(id)
      find_one
    end

    def find_one
      klass.new fetch(klass.resource_path).data
    end

    def find_some
      request = fetch(klass.collection_path)
      Collection.new request.data.map { |record| klass.new(record) }, request.metadata
    end

    def each
      find_some.each { |record| yield record }
    end

    private

      def strip_slug(id)
        id.to_s.split('-').first
      end

      def scoping
        klass.current_scope = self
        yield
      ensure
        klass.current_scope = nil
      end

      def fetch(path)
        @fetch ||= Request.new(path, @params)
      end

      def method_missing(name, *args, &block)
        if klass.respond_to?(name)
          scoping { klass.send(name) }
        else
          super
        end
      end
  end
end
