module Spike
  module Paths
    extend ActiveSupport::Concern

    module ClassMethods
      def collection_path
        Pathname.new model_name.plural
      end

      def resource_path
        collection_path.join ':id'
      end
    end
  end
end
