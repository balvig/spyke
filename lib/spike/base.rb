require 'active_model'
require 'spike/associations'
require 'spike/attributes'
require 'spike/orm'
require 'spike/http'

module Spike
  module Base
    extend ActiveSupport::Concern

    # Spike
    include Associations
    include Attributes
    include Http
    include Orm

    # ActiveModel
    include ActiveModel::Conversion

    included do
      extend ActiveModel::Translation
    end

  end
end
