class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.string :category_name
      t.integer :price
      t.datetime :delivery_date
      t.text :description

      t.timestamps
    end
  end
end
