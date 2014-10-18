require 'active_model'
require 'spike/associations'
require 'spike/attributes'
require 'spike/orm'
require 'spike/default_paths'
require 'spike/http'

module Spike
  module Base
    extend ActiveSupport::Concern

    # Spike
    include Associations
    include Attributes
    include DefaultPaths
    include Http
    include Orm

    # ActiveModel
    include ActiveModel::Conversion

    included do
      extend ActiveModel::Translation
    end

    module ClassMethods
      def collection_path
        Path.new model_name.plural
      end

      def resource_path
        collection_path.join ':id'
      end
    end
  end
end
