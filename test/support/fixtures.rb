class Recipe < Spike::Base
  has_many :groups
  has_one :image
  has_one :background_image, class_name: 'Image'
  has_one :alternate, class_name: 'Recipe', uri_template: '/recipes/:recipe_id/alternates/recipe'
  belongs_to :user

  scope :published, -> { where(status: 'published') }
  attributes :title

  before_save :before_save_callback
  before_create :before_create_callback
  before_update :before_update_callback

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

  def ingredients
    groups.first.ingredients
  end

  private

    def before_create_callback; end
    def before_update_callback; end
    def before_save_callback; end

end

class Image < Spike::Base
  method_for :create, :put
end

class StepImage < Image
end

class Group < Spike::Base
  has_many :ingredients
end

class Ingredient < Spike::Base
  uri_template '/recipes/:recipe_id/ingredients/:id'
end

class User < Spike::Base
  has_many :recipes
end

class Photo < Spike::Base
  uri_template '/images/photos/:id'
end
