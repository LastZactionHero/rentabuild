class HomeController < ApplicationController
  before_filter :redirect_if_logged_in

  layout "landing"

  def index

  end

  def contact_us
    render layout: "application"
  end

  def contact_us_email
    ContactMailer.contact_us_received(
      params[:name],
      params[:email],
      params[:phone],
      params[:message]
    ).deliver

    flash[:notice] = "Thank you for reaching out! We will be in touch shortly."
    redirect_to contact_us_path
  end

  private

  def redirect_if_logged_in
    redirect_to dashboard_path if current_user
  end

end
