class RentalsController < ApplicationController

  def new

  end

  def validate_dates
    start_date_str = params.delete(:start_date)
    duration = params.delete(:duration).to_i
    end_date_str = params.delete(:end_date)

    unless start_date_str && duration > 0
      render status: 400, json: {error: "Start date and duration must be present"}
      return
    end
    
    start_date = DateTime.parse(start_date_str).to_time
    end_date = start_date + duration.days
    available = Rental.are_dates_available?(start_date, end_date)

    if available
      render status: 200, json: {available: true}
    else
      windows = Rental.rental_windows(DateTime.now, 6.months.from_now)
      render status: 200, json: {available: false, windows: windows}
    end

  end

  def quote
    start_date_str = params.delete(:start_date)
    duration = params.delete(:duration).to_i
    shipping = params.delete(:shipping)

    rental_cost = {
      7 => 150.00,
      14 => 250.00,
      21 => 350.00,
      30 => 450.00
    }[duration]

    shipping_cost = {
      "local" => 0.00,
      "national" => 50.00
    }[shipping]

    unless rental_cost && shipping_cost
      errors = {}
      errors[:duration] = "is not valid" unless rental_cost
      errors[:shipping] = "is not valid" unless shipping_cost
      render status: 400, json: {errors: errors} and return
    end

    total_cost = rental_cost + shipping_cost

    render status: 200, json: {
      model: "Makerbot Replicator 5",
      shipping_cost: shipping_cost,
      rental_cost: rental_cost,
      total_cost: total_cost
    }

  end

  def rent
    # Start Date
    # Duration
    # Shipping
    # Name
    # Email
    # Phone
    # Address Line 1
    # Address Line 2
    # Unit
    # Zipcode
    # Stripe Card Token
    # Stripe Charge ID
    
    Stripe.api_key = APP_SETTINGS["stripe"]["api_key"]
    begin
    @response = Stripe::Customer.create(
      description: @user.to_s,
      card: @stripe_card_token)
      true
    rescue Stripe::CardError => e
      @error = e.message
      false
    end    
  end

end