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

  def recent
    weeks = params[:weeks].to_i || 1

    signups = LandingPageSignup.where("created_at > ?", weeks.weeks.ago)
    emails = signups.map(&:email)

    emails.reject!{|e| 
      LandingPageSignup.
        where(email: e).
        where("created_at < ?", weeks.weeks.ago).
        any?
    }

    render status: 200, text: emails.join("<br/>")
  end

end