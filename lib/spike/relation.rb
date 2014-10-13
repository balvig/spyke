require 'spike/collection'
require 'spike/request'

module Spike
  class Relation
    include Enumerable

    attr_reader :klass, :params
    delegate :to_ary, :size, :metadata, to: :find_some

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
      @find_one ||= begin
        result = fetch(resource_path)
        klass.new result.data
      end
    end

    def find_some
      @find_some ||= begin
        result = fetch(collection_path)
        Collection.new result.data.map { |record| klass.new(record) }, result.metadata
      end
    end

    def new
      klass.new(params)
    end
    alias :build :new

    def each
      find_some.each { |record| yield record }
    end

    private

      def strip_slug(id)
        id.to_s.split('-').first
      end

      def fetch(path)
        Request.new(path, params).result
      end

      def method_missing(name, *args, &block)
        if klass.respond_to?(name)
          scoping { klass.send(name) }
        else
          super
        end
      end

      # Keep hold of current scope while running a method on the class
      def scoping
        klass.current_scope = self
        yield
      ensure
        klass.current_scope = nil
      end

  end
end
