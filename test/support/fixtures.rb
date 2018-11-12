# Dummy api
class JSONParser < Faraday::Response::Middleware
  def parse(body)
    json = MultiJson.load(body, symbolize_keys: true)
    {
      data: json[:result],
      metadata: json[:metadata],
      errors: json[:errors]
    }
  rescue MultiJson::ParseError => exception
    { errors: { base: [ error: exception.message ] } }
  end
end

Spyke::Base.connection = Faraday.new(url: 'http://sushi.com') do |faraday|
  faraday.request   :json
  faraday.use       JSONParser
  faraday.adapter   Faraday.default_adapter
end

# Test classes
class Recipe < Spyke::Base
  has_many :groups
  has_many :gallery_images, class_name: 'Image'
  has_one :image
  has_many :step_images
  has_one :background_image, class_name: 'Image', uri: nil
  has_one :alternate, class_name: 'Recipe', uri: 'recipes/:recipe_id/alternates/recipe'
  belongs_to :user

  scope :published, -> { where(status: 'published') }
  scope :approved, -> { where(approved: true) }
  attributes :title, :description

  before_save :before_save_callback
  before_create :before_create_callback
  before_update :before_update_callback

  accepts_nested_attributes_for :image, :user, :groups

  def self.page(number = nil)
    result = all
    result = result.where(page: number) if number
    result
  end

  def description
    super
  end

  def ingredients
    groups.flat_map(&:ingredients)
  end

  private

    def before_create_callback; end
    def before_update_callback; end
    def before_save_callback; end
end

class Image < Spyke::Base
  method_for :create, :put
  attributes :description, :caption
end

class StepImage < Image
  include_root_in_json 'step_image_root'
  attributes :note
end

class RecipeImage < Image
  uri 'recipes/:recipe_id/image'
  validates :url, presence: true
  attributes :url

  include_root_in_json false
end

class Group < Spyke::Base
  has_many :ingredients, uri: nil
  accepts_nested_attributes_for :ingredients

  def self.build_default
    group_1 = build(name: 'Condiments')
    group_1.ingredients.build(name: 'Salt')
    group_2 = build(name: 'Tools')
    group_2.ingredients.build(name: 'Spoon')
  end
end

class Ingredient < Spyke::Base
  uri 'recipes/:recipe_id/ingredients/(:id)'
end

class User < Spyke::Base
  self.primary_key = :uuid
  has_many :recipes
end

class Photo < Spyke::Base
  uri 'images/photos/(:id)'
end

class Comment < Spyke::Base
  belongs_to :user
  has_many :users
  scope :approved, -> { where(comment_approved: true) }
  accepts_nested_attributes_for :users
end

class OtherApi < Spyke::Base
  self.connection = Faraday.new(url: 'http://sashimi.com') do |faraday|
    faraday.use       JSONParser
    faraday.adapter   Faraday.default_adapter
  end
end

class OtherRecipe < OtherApi; end

class Search
  def initialize(query)
    @query = query
  end

  def recipes
    @recipes ||= Recipe.where(query: @query)
  end

  def suggestions
    recipes.metadata[:suggestions]
  end
end

module Cookbook
  class Tip < Spyke::Base
    uri 'tips/(:id)'
    has_many :likes, class_name: 'Cookbook::Like'
    has_many :favorites
    has_many :votes
    has_many :photos, class_name: 'Photo'
  end

  class Like < Spyke::Base
    belongs_to :tip
  end

  class Favorite < Spyke::Base
  end

  class Photo < Spyke::Base
    include_root_in_json :foto
  end
end

class RecipeWithDirty < Recipe
  # NOTE: Simply including ActiveModel::Dirty doesn't provide all the dirty
  # functionality. This is left intentionally incomplete as it's all we need
  # for testing compatibility.
  include ActiveModel::Dirty
end
