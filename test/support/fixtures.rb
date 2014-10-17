class Recipe
  include Spike::Base
  has_many :groups
  has_one :image
  has_one :background_image, class_name: 'Image'
  belongs_to :user

  scope :published, -> { where(status: 'published') }

  def self.page(number)
    if number.present?
      where(page: number)
    else
      all
    end
  end

  def self.recent
    get '/recipes/recent'
  end

  def publish!
    put "/recipes/#{id}/publish"
  end

  def draft!
    put :draft
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
  has_many :recipes
end
