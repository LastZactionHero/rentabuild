require 'spec_helper'

describe RentalsController do
  render_views

  describe 'validate_dates' do

    it 'returns 400 if no dates are provided' do
      get 'validate_dates'
      expect(response.status).to eq(400)

      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Start date and duration must be present")
    end

    it 'returns 400 if a printer is not provided' do
      start_date = 20.days.from_now
      duration = 7

      get 'validate_dates', start_date: start_date.to_s, duration: duration
      expect(response.status).to eq(400)

      body = JSON.parse(response.body)
      expect(body["errors"]["printer_id"]).to include("can't be blank")
    end

    it 'returns successfully if dates are available' do
      start_date = 20.days.from_now
      duration = 7

      get 'validate_dates', start_date: start_date.to_s, duration: duration, printer_id: 0
      expect(response).to be_success
      body = JSON.parse(response.body)
      expect(body["available"]).to eq(true)
    end

    it 'returns suggestions if dates are not available' do
      start_date = 20.days.from_now
      end_date = 27.days.from_now
      duration = 7
      FactoryGirl.create(:rental, start_date: start_date, end_date: end_date)

      get 'validate_dates', start_date: start_date.to_s, duration: duration, printer_id: 0
      expect(response).to be_success
      body = JSON.parse(response.body)
      expect(body["available"]).to eq(false)
      expect(body["windows"].length).to eq(3)
    end

  end

  describe 'quote' do

    it 'returns 400 if no date and shipping information are provided' do
      get 'quote'
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body["errors"]["duration"]).to eq("is not valid")
      expect(body["errors"]["shipping"]).to eq("is not valid")
    end

    it 'returns a cost for 7 days' do
      duration = 7
      shipping = 'local'

      get 'quote', duration: duration, shipping: shipping, printer_id: 0
      expect(response).to be_success

      body = JSON.parse(response.body)
      expect(body["rental_cost"]).to eq(150.00)
      expect(body["total_cost"]).to eq(150.00)
      expect(body["model"]).to eq("Ultimaker II")
      expect(body["shipping_cost"]).to eq(0)
    end

    it 'returns a cost for 14 days' do
      duration = 14
      shipping = 'local'

      get 'quote', duration: duration, shipping: shipping, printer_id: 0
      expect(response).to be_success

      body = JSON.parse(response.body)
      expect(body["rental_cost"]).to eq(250.00)
      expect(body["total_cost"]).to eq(250.00)
      expect(body["model"]).to eq("Ultimaker II")
      expect(body["shipping_cost"]).to eq(0)
    end

    it 'returns a cost for 21 days' do
      duration = 21
      shipping = 'local'

      get 'quote', duration: duration, shipping: shipping, printer_id: 0
      expect(response).to be_success

      body = JSON.parse(response.body)
      expect(body["rental_cost"]).to eq(350.00)
      expect(body["total_cost"]).to eq(350.00)
      expect(body["model"]).to eq("Ultimaker II")
      expect(body["shipping_cost"]).to eq(0)
    end

    it 'returns a cost for 30 days' do
      duration = 30
      shipping = 'local'

      get 'quote', duration: duration, shipping: shipping, printer_id: 0
      expect(response).to be_success

      body = JSON.parse(response.body)
      expect(body["rental_cost"]).to eq(400.00)
      expect(body["total_cost"]).to eq(400.00)
      expect(body["model"]).to eq("Ultimaker II")
      expect(body["shipping_cost"]).to eq(0)
    end

    it 'returns a cost for 90 days' do
      duration = 90
      shipping = 'local'

      get 'quote', duration: duration, shipping: shipping, printer_id: 0
      expect(response).to be_success

      body = JSON.parse(response.body)
      expect(body["rental_cost"]).to eq(1100.00)
      expect(body["total_cost"]).to eq(1100.00)
      expect(body["model"]).to eq("Ultimaker II")
      expect(body["shipping_cost"]).to eq(0)
    end

    it 'returns a cost for national shipping' do
      duration = 7
      shipping = 'national'

      get 'quote', duration: duration, shipping: shipping, printer_id: 0
      expect(response).to be_success

      body = JSON.parse(response.body)
      expect(body["rental_cost"]).to eq(150.0)
      expect(body["model"]).to eq("Ultimaker II")
      expect(body["shipping_cost"]).to eq(50.00)
      expect(body["total_cost"]).to eq(200.00)
    end

    describe 'promo codes' do

      it 'adds free shipping' do
        promo_code = FactoryGirl.create(:promo_code, free_shipping: true)
        duration = 7
        shipping = 'national'

        get 'quote',
          duration: duration,
          shipping: shipping,
          promo_code: promo_code.code,
          printer_id: 0

        expect(response).to be_success
        body = JSON.parse(response.body)
        expect(body["rental_cost"]).to eq(150.0)
        expect(body["shipping_cost"]).to eq(0.00)
        expect(body["total_cost"]).to eq(150.00)
        expect(body["promo_code"]["code"]).to eq(promo_code.code)
        expect(body["promo_code"]["description"]).to eq(promo_code.description)
        expect(body["promo_code"]["valid"]).to eq(true)
      end

      it 'takes a fixed amount off a rental' do
        promo_code = FactoryGirl.create(:promo_code, amount_off: 50.0)
        duration = 7
        shipping = 'national'

        get 'quote',
          duration: duration,
          shipping: shipping,
          promo_code: promo_code.code,
          printer_id: 0

        expect(response).to be_success
        body = JSON.parse(response.body)
        expect(body["rental_cost"]).to eq(100.0)
        expect(body["shipping_cost"]).to eq(50.00)
        expect(body["total_cost"]).to eq(150.00)
        expect(body["promo_code"]["code"]).to eq(promo_code.code)
        expect(body["promo_code"]["description"]).to eq(promo_code.description)
        expect(body["promo_code"]["valid"]).to eq(true)
      end

      it 'takes a fixed amount off a rental for a specific duration' do
        promo_code = FactoryGirl.create(:promo_code, amount_off: 50.0, duration: 7)
        duration = 7
        shipping = 'national'

        get 'quote',
          duration: duration,
          shipping: shipping,
          promo_code: promo_code.code,
          printer_id: 0

        expect(response).to be_success
        body = JSON.parse(response.body)
        expect(body["rental_cost"]).to eq(100.0)
        expect(body["shipping_cost"]).to eq(50.00)
        expect(body["total_cost"]).to eq(150.00)
        expect(body["promo_code"]["code"]).to eq(promo_code.code)
        expect(body["promo_code"]["description"]).to eq(promo_code.description)
        expect(body["promo_code"]["valid"]).to eq(true)
      end

      it 'indicates an invalid promo code' do
        duration = 7
        shipping = 'national'

        get 'quote',
          duration: duration,
          shipping: shipping,
          promo_code: "INVALID CODE",
          printer_id: 0

        expect(response).to be_success
        body = JSON.parse(response.body)
        expect(body["rental_cost"]).to eq(150.0)
        expect(body["shipping_cost"]).to eq(50.00)
        expect(body["total_cost"]).to eq(200.00)
        expect(body["promo_code"]["code"]).to eq("INVALID CODE")
        expect(body["promo_code"]["valid"]).to eq(FALSE)
        expect(body["promo_code"]["error"]).to eq("This code is not valid.")
      end

      it 'indicates an invalid promo code for a duration' do
        promo_code = FactoryGirl.create(:promo_code, amount_off: 50.0, duration: 14)
        duration = 7
        shipping = 'national'

        get 'quote',
          duration: duration,
          shipping: shipping,
          promo_code: promo_code.code,
          printer_id: 0

        expect(response).to be_success
        body = JSON.parse(response.body)
        expect(body["rental_cost"]).to eq(150.0)
        expect(body["shipping_cost"]).to eq(50.00)
        expect(body["total_cost"]).to eq(200.00)
        expect(body["promo_code"]["code"]).to eq(promo_code.code)
        expect(body["promo_code"]["description"]).to eq(promo_code.description)
        expect(body["promo_code"]["valid"]).to eq(false)
        expect(body["promo_code"]["error"]).to eq("This code is not valid for this rental length.")
      end

    end
  end

  describe 'rent' do
    let(:start_date){DateTime.parse("February 1, 2015")}
    let(:duration){7}
    let(:shipping){"national"}
    let(:name){"Printer Renterson"}
    let(:email){"printer@rental.com"}
    let(:address_line_1){"368 W Cherrywood"}
    let(:zipcode){80026}
    let(:phone){"317-496-8472"}
    let(:stripe_card_token){"tok_15HR1B4yIhAxEA8eCYJjjuth"}

    it 'responds with an error if date and duration are not provided' do
      post 'rent'
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Start date and duration must be present")
    end

    it 'responds with an error if shipping is not provided' do
      post 'rent', start_date: start_date, duration: duration

      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body["errors"]["shipping"]).to eq("is not valid")
    end

    it 'responds with an error if contact information is not provided' do
      post 'rent',
        start_date: start_date,
        duration: duration,
        shipping: shipping,
        printer_id: 0

      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Name can't be blank")
      expect(body["errors"]).to include("Phone can't be blank")
      expect(body["errors"]).to include("Email can't be blank")
      expect(body["errors"]).to include("Address line 1 can't be blank")
      expect(body["errors"]).to include("Zipcode can't be blank")
      expect(body["errors"]).to include("Stripe card token can't be blank")
    end

    it 'responds with an error if dates are not available' do
      FactoryGirl.create(:rental, start_date: start_date, end_date: start_date + duration.day)

      post 'rent', start_date: start_date,
        duration: duration,
        shipping: shipping,
        name: name,
        phone: phone,
        email: email,
        address_line_1: address_line_1,
        zipcode: zipcode,
        stripe_card_token: stripe_card_token,
        printer_id: 0

      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Start date is unavailable")
    end

    it 'successfully creates a rental' do
      VCR.use_cassette("successful_rental") do
        post 'rent', start_date: start_date,
          duration: duration,
          shipping: shipping,
          name: name,
          phone: phone,
          email: email,
          address_line_1: address_line_1,
          zipcode: zipcode,
          stripe_card_token: stripe_card_token,
          printer_id: 0

        expect(response.status).to eq(200)
      end
    end

    it 'successfully creates a rental for a different printer' do
      VCR.use_cassette("successful_rental") do
        printer_id = 1

        post 'rent', start_date: start_date,
          duration: duration,
          shipping: shipping,
          name: name,
          phone: phone,
          email: email,
          address_line_1: address_line_1,
          zipcode: zipcode,
          stripe_card_token: stripe_card_token,
          printer_id: printer_id

        expect(response.status).to eq(200)

        rental = Rental.first
        expect(rental.printer.id).to eq(printer_id)
      end
    end

    it 'successfully creates a rental with a promo code' do
      promo_code = FactoryGirl.create(:promo_code, amount_off: 50, free_shipping: true)

      VCR.use_cassette("successful_rental") do
        post 'rent', start_date: start_date,
          duration: duration,
          shipping: shipping,
          name: name,
          phone: phone,
          email: email,
          address_line_1: address_line_1,
          zipcode: zipcode,
          stripe_card_token: stripe_card_token,
          promo_code: promo_code.code,
          printer_id: 0

        expect(response.status).to eq(200)

        rental = Rental.last
        expect(rental.promo_code).to eq(promo_code)
        expect(rental.amount).to eq(100)
      end
    end

  end

end
