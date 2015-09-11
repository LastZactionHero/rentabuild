require 'spec_helper'

describe PrintersController do

  describe 'prices' do

    it 'returns the prices for a printer' do
      printer = Printer.all.first

      get 'prices', id: printer.id

      expect(response).to be_success

      body = JSON.parse(response.body)
      body.keys.each do |duration|
        expect(body[duration]).to eq(printer.price_for_duration(duration.to_i))
      end
    end

    it 'returns 404 if the printer id is invalid' do
      get 'prices', id: 100000
      expect(response.status).to eq(404)
    end

  end

end
