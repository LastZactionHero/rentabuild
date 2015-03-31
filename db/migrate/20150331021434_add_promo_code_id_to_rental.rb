class AddPromoCodeIdToRental < ActiveRecord::Migration
  def change
    add_column :rentals, :promo_code_id, :integer
  end
end
