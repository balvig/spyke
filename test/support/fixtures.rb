class Recipe
  include Spike::Base
  has_many :groups
  has_one :image
  has_one :background_image, class_name: 'Image'

  scope :page, -> { where(per_page: 3) }

  def self.published
    where(status: 'published')
  end

  def self.recent
    get '/recipes/recent'
  end

  def publish!
    put "/recipes/#{id}/publish"
  end

  def ingredients
    groups.first.ingredients
  end
end

class Image
  include Spike::Base
end

class Group
  include Spike::Base
  has_many :ingredients
end

class Ingredient
  include Spike::Base
end

class User
  include Spike::Base
end
