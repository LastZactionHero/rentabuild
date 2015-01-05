class RentalsController < ApplicationController
  before_filter :find_dates_or_fail, only: [:validate_dates, :rent]
  before_filter :find_cost_or_fail, only: [:quote, :rent]

  protect_from_forgery except: [:rent]

  def new

  end

  def validate_dates
    available = Rental.are_dates_available?(@start_date, @end_date)

    if available
      render status: 200, json: {available: true}
    else
      windows = Rental.rental_windows(DateTime.now, 6.months.from_now)
      render status: 200, json: {available: false, windows: windows}
    end

  end

  def quote    
    render status: 200, json: {
      model: "Makerbot Replicator 5",
      shipping_cost: @shipping_cost,
      rental_cost: @rental_cost,
      total_cost: @total_cost
    }
  end

  def rent
    card_token = params.delete(:stripe_card_token)

    # New Rental
    rental = Rental.new(
      start_date: @start_date,
      end_date: @end_date,
      duration: @duration,
      shipping: @shipping,
      name: params.delete(:name),
      email: params.delete(:email),
      phone: params.delete(:phone),
      address_line_1: params.delete(:address_line_1),
      address_line_2: params.delete(:address_line_2),
      zipcode: params.delete(:zipcode),
      amount: @total_cost,
      stripe_card_token: card_token
    )

    # Validate Rental
    unless rental.valid?
      render status: 400, json: {errors: rental.errors.full_messages.join(", ")} and return
    end

    # Charge for Rental
    Stripe.api_key = APP_SETTINGS["stripe"]["api_key"]
    begin
      customer = Stripe::Customer.create(
        description: rental.email,
        card: card_token)


      charge = Stripe::Charge.create(
        customer: customer.id,
        amount: (@total_cost * 100).to_i,
        description: "RentABuild Printer Rental",
        currency: "usd")

      rental.stripe_charge_id = charge.id
      rental.save
  
    rescue Stripe::CardError => e
      render status: 400, json: {errors: e.message} and return
    end

    render status: 200, json: {
      start_date: rental.start_date,
      end_date: rental.end_date,
      duration: rental.duration,
      shipping: rental.shipping,
      name: rental.name,
      email: rental.email,
      phone: rental.phone,
      address_line_1: rental.address_line_1,
      address_line_2: rental.address_line_2,
      zipcode: rental.zipcode,
      amount: rental.amount
    }
  end

  def success

  end
  
  private

  def find_dates_or_fail
    start_date_str = params.delete(:start_date)
    @duration ||= params.delete(:duration).to_i
    end_date_str = params.delete(:end_date)

    unless start_date_str && @duration > 0
      render status: 400, json: {error: "Start date and duration must be present"}
      return
    end
    
    @start_date ||= DateTime.parse(start_date_str).to_time
    @end_date ||= @start_date + @duration.days
  end

  def find_cost_or_fail
    start_date_str = params.delete(:start_date)
    @duration ||= params.delete(:duration).to_i
    @shipping ||= params.delete(:shipping)

    @rental_cost = {
      7 => 150.00,
      14 => 250.00,
      21 => 350.00,
      30 => 400.00
    }[@duration]

    @shipping_cost = {
      "local" => 0.00,
      "national" => 50.00
    }[@shipping]

    unless @rental_cost && @shipping_cost
      errors = {}
      errors[:duration] = "is not valid" unless @rental_cost
      errors[:shipping] = "is not valid" unless @shipping_cost
      render status: 400, json: {errors: errors} and return
    end

    @total_cost = @rental_cost + @shipping_cost
  end


end