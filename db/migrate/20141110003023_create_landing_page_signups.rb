class CreateLandingPageSignups < ActiveRecord::Migration
  def change
    create_table :landing_page_signups do |t|
      t.string :email
      t.string :zipcode
      t.string :model_name
      t.string :duration

      t.timestamps
    end
  end
end
