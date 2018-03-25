class CreatePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :payments do |t|
      t.integer :order_id
      t.integer :sn, null: false
      t.string :payment_method
      t.integer :amount
      t.datetime :paid_at
      t.text :params
      t.timestamps
    end
  end
end
