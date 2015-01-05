class AddFieldsToRentals < ActiveRecord::Migration
  def change
    add_column :rentals, :duration, :integer
    add_column :rentals, :shipping, :string
    add_column :rentals, :name, :string
    add_column :rentals, :email, :string
    add_column :rentals, :phone, :string
    add_column :rentals, :address_line_1, :string
    add_column :rentals, :address_line_2, :string
    add_column :rentals, :unit, :string
    add_column :rentals, :zipcode, :string
    add_column :rentals, :stripe_card_token, :string
    add_column :rentals, :stripe_charge_id, :string
    add_column :rentals, :amount, :decimal
  end
end
