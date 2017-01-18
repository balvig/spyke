require 'spyke/exceptions'

module Spyke
  class Relation
    include Enumerable

    attr_reader :klass
    attr_accessor :params
    delegate :to_ary, :[], :any?, :empty?, :last, :size, :metadata, to: :find_some

    def initialize(klass, options = {})
      @klass = klass
      @options = options
      @params = {}
      @should_fallback = false
    end

    def where(conditions = {})
      relation = clone
      relation.params = params.merge(conditions)
      relation
    end

    def with(uri)
      if uri.is_a? Symbol
        @options[:uri] = File.join @options[:uri], uri.to_s
      else
        @options[:uri] = uri
      end
      where
    end

    def with_fallback(fallback = nil)
      @should_fallback = true
      @fallback = fallback
      where
    end

    # Overrides Enumerable find
    def find(id)
      scoping { klass.find(id) }
    end

    def find_one
      @find_one ||= klass.new_instance_from_result(fetch)
    rescue ConnectionError => error
      fallback_or_reraise(error, default: nil)
    end

    def find_some
      @find_some ||= klass.new_collection_from_result(fetch)
    rescue ConnectionError => error
      fallback_or_reraise(error, default: [])
    end

    def each(&block)
      find_some.each(&block)
    end

    def uri
      @options[:uri]
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
        previous, klass.current_scope = klass.current_scope, self
        yield
      ensure
        klass.current_scope = previous
      end

      def fallback_or_reraise(error, default:)
        if should_fallback?
          @fallback || default
        else
          raise error
        end
      end

      def should_fallback?
        @should_fallback
      end
  end
end
