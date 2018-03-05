class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.integer :sn
      t.integer :amount
      t.integer :user_id
      t.string :name
      t.string :phone
      t.string :address
      t.string :payment_status, default: "not_paid"
      t.string :shipping_status, default: "not_shipped"
      t.timestamps
    end
  end
end
