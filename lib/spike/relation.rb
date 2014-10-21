require 'spike/collection'
require 'spike/exceptions'

module Spike
  class Relation
    include Enumerable

    attr_reader :klass, :params
    delegate :to_ary, :empty?, :size, :metadata, to: :find_some

    def initialize(klass, params = {})
      @klass, @params = klass, params
    end

    def where(conditions = {})
      @params.merge!(conditions)
      self
    end

    def find(id)
      params[:id] = strip_slug(id)
      find_one || raise(ResourceNotFound)
    end

    def find_one
      @find_one ||= klass.new_from_result(fetch)
    end

    def find_some
      @find_some ||= klass.new_collection_from_result(fetch)
    end

    def each
      find_some.each { |record| yield record }
    end

    def new(attributes = {})
      klass.new params.merge(attributes)
    end

    def build(*args)
      new(*args)
    end

    def create(attributes = {})
      record = new(attributes)
      record.save
      record
    end

    private

      def path
        klass.new(params).path
      end

      def fetch
        klass.get_raw(path, params)
      end

      def strip_slug(id)
        id.to_s.split('-').first
      end

      def method_missing(name, *args, &block)
        if klass.respond_to?(name)
          scoping { klass.send(name, *args) }
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
