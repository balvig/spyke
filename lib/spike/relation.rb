require 'spike/exceptions'

module Spike
  class Relation
    include Enumerable

    attr_reader :klass, :params
    delegate :to_ary, :empty?, :size, :metadata, to: :find_some

    def initialize(klass, options = {})
      @klass, @options, @params = klass, options, {}
    end

    def all
      where
    end

    def where(conditions = {})
      @params.merge!(conditions)
      self
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

    def uri_template
      @options[:uri_template]
    end

    private

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
