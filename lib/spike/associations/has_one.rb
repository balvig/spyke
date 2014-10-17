require 'spike/associations/association'

module Spike
  module Associations
    class HasOne < Association

      def resource_path
        Pathname.new File.join owner.class.collection_path, ":#{owner.foreign_key}", klass.model_name.singular
      end

    end
  end
end
