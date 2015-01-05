# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rental do
    start_date "2014-12-14 09:57:29"
    end_date "2014-12-20 09:57:29"
    duration 6
    shipping 'local'
    name 'Printer Renterson'
    email 'printer@rental.com'
    phone '317-496-8472'
    address_line_1 '368 W Cherrywood Dr'
    zipcode '80026'
    stripe_card_token 'tok_123'
    stripe_charge_id 'ch_123'
    amount 200.00
  end
end
