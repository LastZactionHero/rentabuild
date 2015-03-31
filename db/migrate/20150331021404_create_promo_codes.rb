class CreatePromoCodes < ActiveRecord::Migration
  def change
    create_table :promo_codes do |t|
      t.string :code
      t.string :description
      t.float :amount_off
      t.boolean :free_shipping
      t.integer :duration

      t.timestamps
    end
  end
end
