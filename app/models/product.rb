class Product < ApplicationRecord
  validates :name, presence: true
  validates :price, presence: true

  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items
end
