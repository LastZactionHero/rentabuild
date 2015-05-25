class AddPrinterIdToRental < ActiveRecord::Migration
  def change
    add_column :rentals, :printer_id, :integer, default: 0
  end
end
