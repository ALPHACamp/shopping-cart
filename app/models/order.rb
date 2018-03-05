class Order < ApplicationRecord
  validates_presence_of :name, :address, :phone, :payment_status, :shipping_status

  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
end
