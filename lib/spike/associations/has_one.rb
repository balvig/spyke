require 'spike/associations/association'

module Spike
  module Associations
    class HasOne < Association

      def initialize(*args)
        super
        @params = { foreign_key => owner.try(:id) }
      end

      def resource_path
        Pathname.new File.join owner.class.collection_path, ":#{foreign_key}", klass.model_name.singular
      end

    end
  end
end
