require 'spike/associations/association'

module Spike
  module Associations
    class HasMany < Association

      def initialize(*args)
        super
      end

      def collection_path
        Pathname.new File.join owner.class.collection_path, ":#{@owner.foreign_key}", klass.collection_path
      end

      def resource_path
        collection_path.join ':id'
      end
    end
  end
end
