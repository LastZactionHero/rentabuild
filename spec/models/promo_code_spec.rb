require 'rails_helper'

RSpec.describe PromoCode, :type => :model do
  
  describe 'validations' do

    it 'must have a code' do
      pc = PromoCode.create()
      expect(pc.errors[:code]).to eq(["can't be blank"])
    end

    it 'must have a description' do
      pc = PromoCode.create()
      expect(pc.errors[:description]).to eq(["can't be blank"])
    end

    it 'must have an amount off or free shipping' do
      pc = PromoCode.create()
      expect(pc.errors[:amount_off]).to eq(["something must be discounted"])
      expect(pc.errors[:free_shipping]).to eq(["something must be discounted"])
    end

    it 'creates successfully' do
      pc = PromoCode.create(
        code: "MYCODE",
        description: "$50 off a rental",
        amount_off: 50,        
      )
      expect(pc.id).to be_present
    end

  end

end
