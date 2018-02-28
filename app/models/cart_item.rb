class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  def item_total
    self.quantity * self.product.price
  end
end
