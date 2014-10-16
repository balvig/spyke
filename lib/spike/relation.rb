require 'spike/collection'

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
      @find_one ||= klass.new_from_result fetch(resource_path)
    end

    def find_some
      @find_some ||= klass.new_collection_from_result fetch(collection_path)
    end

    def each
      find_some.each { |record| yield record }
    end

    def new(attributes = {})
      klass.new(params.merge(attributes))
    end
    alias :build :new

    def create(attributes = {})
      klass.post collection_path, params.merge(attributes)
    end

    private

      def fetch(path)
        klass.get_raw(path, params)
      end

      def strip_slug(id)
        id.to_s.split('-').first
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
