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

    it 'returns successfully if dates are available' do
      start_date = 20.days.from_now
      duration = 7

      get 'validate_dates', start_date: start_date.to_s, duration: duration
      expect(response).to be_success
      body = JSON.parse(response.body)
      expect(body["available"]).to eq(true)
    end

    it 'returns suggestions if dates are not available' do
      start_date = 20.days.from_now
      end_date = 27.days.from_now
      duration = 7
      FactoryGirl.create(:rental, start_date: start_date, end_date: end_date)

      get 'validate_dates', start_date: start_date.to_s, duration: duration
      expect(response).to be_success
      body = JSON.parse(response.body)
      expect(body["available"]).to eq(false)
      expect(body["windows"].length).to eq(2)
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

      get 'quote', duration: duration, shipping: shipping
      expect(response).to be_success

      body = JSON.parse(response.body)
      expect(body["rental_cost"]).to eq(150.00)
      expect(body["total_cost"]).to eq(150.00)
      expect(body["model"]).to eq("Makerbot Replicator 5")
      expect(body["shipping_cost"]).to eq(0)
    end

    it 'returns a cost for 14 days' do
      duration = 14
      shipping = 'local'

      get 'quote', duration: duration, shipping: shipping
      expect(response).to be_success

      body = JSON.parse(response.body)
      expect(body["rental_cost"]).to eq(250.00)
      expect(body["total_cost"]).to eq(250.00)
      expect(body["model"]).to eq("Makerbot Replicator 5")
      expect(body["shipping_cost"]).to eq(0)
    end

    it 'returns a cost for 21 days' do
      duration = 21
      shipping = 'local'

      get 'quote', duration: duration, shipping: shipping
      expect(response).to be_success

      body = JSON.parse(response.body)
      expect(body["rental_cost"]).to eq(350.00)
      expect(body["total_cost"]).to eq(350.00)
      expect(body["model"]).to eq("Makerbot Replicator 5")
      expect(body["shipping_cost"]).to eq(0)
    end

    it 'returns a cost for 30 days' do
      duration = 30
      shipping = 'local'

      get 'quote', duration: duration, shipping: shipping
      expect(response).to be_success

      body = JSON.parse(response.body)
      expect(body["rental_cost"]).to eq(450.00)
      expect(body["total_cost"]).to eq(450.00)
      expect(body["model"]).to eq("Makerbot Replicator 5")
      expect(body["shipping_cost"]).to eq(0)
    end

    it 'returns a cost for national shipping' do
      duration = 7
      shipping = 'national'

      get 'quote', duration: duration, shipping: shipping
      expect(response).to be_success

      body = JSON.parse(response.body)
      expect(body["rental_cost"]).to eq(150.0)
      expect(body["model"]).to eq("Makerbot Replicator 5")
      expect(body["shipping_cost"]).to eq(50.00)
      expect(body["total_cost"]).to eq(200.00)
    end

  end

end