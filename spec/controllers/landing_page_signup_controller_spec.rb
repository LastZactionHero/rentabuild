require 'spec_helper'

describe LandingPageSignupsController do
  render_views

  describe 'create' do

    it 'creates a sign up' do
      email = "user@email.com"
      zipcode = "80026"
      model_name = "Makerbot Replicator 2"
      duration = "1 week"

      post :create, {email: email,
        zipcode: zipcode,
        model_name: model_name,
        duration: duration}
      expect(response).to be_success

      expect(LandingPageSignup.count).to eq(1)
      signup = LandingPageSignup.first
      expect(signup.email).to eq(email)
      expect(signup.zipcode).to eq(zipcode)
      expect(signup.model_name).to eq(model_name)
      expect(signup.duration).to eq(duration)
    end

  end
  
end