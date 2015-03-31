# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :promo_code do
    code "MYCODE"
    description "Free something"
    amount_off 0
    free_shipping false
    duration nil
  end
end
