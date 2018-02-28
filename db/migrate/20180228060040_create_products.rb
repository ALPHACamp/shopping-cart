class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.integer :price, null: false
      t.string :image
      t.timestamps
    end
  end
end
