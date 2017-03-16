class DishType < ActiveRecord::Base
  has_many :dishes
  validates :name,
  presence: true
end
