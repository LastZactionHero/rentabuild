class PromoCode < ActiveRecord::Base
  has_many :rentals

  validates_presence_of :code
  validates_presence_of :description

  validate :something_is_discounted

  private

  def something_is_discounted
    unless amount_off && amount_off > 0 || free_shipping
      errors.add(:amount_off, "something must be discounted")
      errors.add(:free_shipping, "something must be discounted")
    end
  end

end
