class Payment < ApplicationRecord
  belongs_to :order

  PAYMENT_METHODS = %w[Credit WebATM ATM]
  validates_inclusion_of :payment_method, in: PAYMENT_METHODS

  def deadline
    Date.today + 3.days
  end
end
