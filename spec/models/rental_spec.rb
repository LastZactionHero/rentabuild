require 'rails_helper'

RSpec.describe Rental, :type => :model do
  
  describe 'validations' do

    it 'must include a start date and end date' do
      rental = Rental.create
      expect(rental.errors[:start_date]).to include("can't be blank")
      expect(rental.errors[:end_date]).to include("can't be blank")
    end

    it 'must have a start date before the end date' do
      start_date = 3.days.from_now
      end_date = 2.days.from_now

      rental = Rental.create(start_date: start_date, end_date: end_date)
      expect(rental.errors[:start_date]).to include("must be before end date")
    end

    it 'cannot overlap with the start of another rental' do
      first_rental_start_date = DateTime.parse("March 3, 2015")
      first_rental_end_date = DateTime.parse("March 20, 2015")
      first_rental = FactoryGirl.create(:rental, 
        start_date: first_rental_start_date,
        end_date: first_rental_end_date)

      second_rental_start_date = DateTime.parse("Februrary 20, 2015")
      second_rental_end_date = DateTime.parse("March 2, 2015")
      second_rental = Rental.create(
        start_date: second_rental_start_date,
        end_date: second_rental_end_date
      )

      expect(second_rental.errors[:start_date]).to include("is unavailable")
    end

    it 'cannot overlap with the end of another rental' do
      first_rental_start_date = DateTime.parse("March 3, 2015")
      first_rental_end_date = DateTime.parse("March 20, 2015")
      first_rental = FactoryGirl.create(:rental, 
        start_date: first_rental_start_date,
        end_date: first_rental_end_date)

      second_rental_start_date = DateTime.parse("March 23, 2015")
      second_rental_end_date = DateTime.parse("March 30, 2015")
      second_rental = Rental.create(
        start_date: second_rental_start_date,
        end_date: second_rental_end_date
      )

      expect(second_rental.errors[:start_date]).to include("is unavailable")
    end

    it 'cannot be within another rental' do
      first_rental_start_date = DateTime.parse("March 3, 2015")
      first_rental_end_date = DateTime.parse("March 20, 2015")
      first_rental = FactoryGirl.create(:rental, 
        start_date: first_rental_start_date,
        end_date: first_rental_end_date)

      second_rental_start_date = DateTime.parse("March 8, 2015")
      second_rental_end_date = DateTime.parse("March 12, 2015")
      second_rental = Rental.create(
        start_date: second_rental_start_date,
        end_date: second_rental_end_date
      )

      expect(second_rental.errors[:start_date]).to include("is unavailable")
    end

    it 'cannot contains another rental' do
      first_rental_start_date = DateTime.parse("March 3, 2015")
      first_rental_end_date = DateTime.parse("March 20, 2015")
      first_rental = FactoryGirl.create(:rental, 
        start_date: first_rental_start_date,
        end_date: first_rental_end_date)

      second_rental_start_date = DateTime.parse("March 1, 2015")
      second_rental_end_date = DateTime.parse("March 30, 2015")
      second_rental = Rental.create(
        start_date: second_rental_start_date,
        end_date: second_rental_end_date
      )

      expect(second_rental.errors[:start_date]).to include("is unavailable")
    end

    it 'creates a rental' do
      start_date = "March 3, 2015"
      end_date = "March 15, 2015"
      rental = Rental.create(start_date: start_date, end_date: end_date)
      expect(rental).to be_valid
    end

    it 'creates a second rental with a valid date range' do
      start_date = "March 3, 2015"
      end_date = "March 15, 2015"
      rental = Rental.create(start_date: start_date, end_date: end_date)
      expect(rental).to be_valid

      start_date = "March 31, 2015"
      end_date = "April 10, 2015"
      rental = Rental.create(start_date: start_date, end_date: end_date)
      expect(rental).to be_valid      
    end

  end

  describe 'prep_start_date' do

    it 'provides a prep start date' do
      rental = FactoryGirl.create(:rental)
      expect(rental.prep_start_date).to eq(rental.start_date - 4.days)
    end

  end

  describe 'prep_end_date' do

    it 'provides a prep end date' do
      rental = FactoryGirl.create(:rental)
      expect(rental.prep_end_date).to eq(rental.end_date + 4.days)
    end

  end

  describe 'rental_window' do
    let(:rental_1){FactoryGirl.create(:rental, 
      start_date: DateTime.parse("February 1, 2015"),
      end_date: DateTime.parse("February 15, 2015"))
    }
    let(:rental_2){
      FactoryGirl.create(:rental, 
        start_date: DateTime.parse("February 23, 2015"),
        end_date: DateTime.parse("March 10, 2015")
      )
    }
    let(:rental_3){
      FactoryGirl.create(:rental, 
        start_date: DateTime.parse("April 9, 2015"),
        end_date: DateTime.parse("April 15, 2015")
      )
    }

    let(:start_date){DateTime.parse("January 1, 2015")}
    let(:end_date){DateTime.parse("June 1, 2015")}
    
    before(:each) do
      rental_1
      rental_2
      rental_3
    end

    it 'provides a list of days for rental within a range' do
      windows = Rental.rental_windows(start_date, end_date)
      expect(windows).to eq([
        {start_date: start_date, end_date: rental_1.start_date - 8.days},
        {start_date: rental_2.end_date + 8.days, end_date: rental_3.start_date - 8.days},
        {start_date: rental_3.end_date + 8.days, end_date: end_date}
      ])
    end

    it 'provides a list of days for rental within a range with a minimum day length' do
      windows = Rental.rental_windows(start_date, end_date, 15)
      expect(windows).to eq([
        {start_date: start_date, end_date: rental_1.start_date - 8.days},
        {start_date: rental_3.end_date + 8.days, end_date: end_date}
      ])
    end

  end

end
