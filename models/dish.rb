class Dish < ActiveRecord::Base
  belongs_to :dish_type
  has_many :comments
  validates :name, :image_url,
  presence: true
end

#d1 = Dish.new(name: 'cake', image_url: 'http////sadasd.com')
#d1.name = 'cake'
