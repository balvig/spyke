require 'active_model'
require 'spyke/associations'
require 'spyke/attributes'
require 'spyke/orm'
require 'spyke/http'
require 'spyke/scopes'

module Spyke
  class Base
    # ActiveModel
    include ActiveModel::Conversion
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    extend ActiveModel::Translation
    extend ActiveModel::Callbacks

    # Spyke
    include Associations
    include Attributes
    include Http
    include Orm
    include Scopes
  end
end
