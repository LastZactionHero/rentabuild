class LandingPageSignupsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def create
    @signup = LandingPageSignup.create(
      email: params[:email],
      zipcode: params[:zipcode],
      model_name: params[:model_name],
      duration: params[:duration]
    )
    render status: 200, json: @signup
  end

end