require 'spike/collection'
require 'spike/request'

module Spike
  class Relation
    include Enumerable

    attr_reader :klass, :params
    delegate :to_ary, :metadata, to: :find_some

    def initialize(klass)
      @klass = klass
      @params = {}
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
      fetch(klass.resource_path) do |request|
        klass.new(request.data)
      end
    end

    def find_some
      fetch(klass.collection_path) do |request|
        Collection.new request.data.map { |record| klass.new(record) }, request.metadata
      end
    end

    def each
      find_some.each { |record| yield record }
    end

    private

      def strip_slug(id)
        id.to_s.split('-').first
      end

      def fetch(path)
        yield @request ||= Request.new(path, @params)
      ensure
        klass.reset_scope!
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
