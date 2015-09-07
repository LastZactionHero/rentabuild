class Rental < ActiveRecord::Base
  validates_presence_of :start_date
  validates_presence_of :end_date
  validate :start_date_before_end_date
  validate :dates_are_available

  validates_presence_of :duration
  validates_presence_of :shipping
  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :phone
  validates_presence_of :address_line_1
  validates_presence_of :zipcode
  validates_presence_of :stripe_card_token
  validates_presence_of :amount
  validates_presence_of :printer_id

  belongs_to :promo_code

  PREP_TIME_DAYS = 4

  def self.rental_windows(options = {})
    minimum_days = options[:minimum_days] || 7

    printers = Printer.all

    printer_windows = []

    printers.each do |printer|
      rentals = Rental.where(printer_id: printer.id)
      year = prep_rental_year(rentals)
      windows = find_rental_windows(year, minimum_days)

      printer_windows << {
        printer: printer,
        windows: windows
      }
    end

    printer_windows
  end

  def prep_start_date
    start_date - PREP_TIME_DAYS.days
  end

  def prep_end_date
    end_date + PREP_TIME_DAYS.days
  end

  def self.are_dates_available?(start_date, end_date, printer_id, id = nil)
    other_rentals = Rental.where("start_date > ? AND start_date < ? OR end_date > ? AND end_date < ?",
      start_date - 2 * PREP_TIME_DAYS.days, end_date + 2 * PREP_TIME_DAYS.days,
      start_date - 2 * PREP_TIME_DAYS.days, end_date + 2 * PREP_TIME_DAYS.days
    ).where(printer_id: printer_id)
    other_rentals = other_rentals.where("id != ?", id) if id

    printer = Printer.find_by_id(printer_id)
    other_rentals.count < printer.inventory
  end

  def printer
    Printer.find_by_id(printer_id)
  end

  private

  def self.find_rental_windows(year, minimum_days)
    windows = []
    current_window = nil
    year.each do |day|
      if day[:available] && current_window
        # Keep adding to the current window
        current_window << day
      elsif day[:available] && !current_window
        # Start of a new window
        in_window = true
        current_window = [day]
      elsif !day[:available] && current_window
        # End of a window
        windows << current_window
        current_window = nil
      end
    end
    if current_window
      windows << current_window
      current_window = nil
    end

    windows.reject!{|w| w.length < minimum_days}
    windows.map{|w| {start_date: w.first[:day].to_datetime, end_date: w.last[:day].to_datetime}}
  end

  def self.prep_rental_year(rentals)
    year = Array.new(365)
    year.each_with_index do |day, idx|
      day = idx.day.from_now.beginning_of_day
      year[idx] = {
        day: day,
        day_of_week: day.wday,
        available: true
      }
    end

    # Identify any rentals in the next year
    rentals.all.each do |rental|
      seconds_from_now = rental.start_date.to_i - DateTime.now.beginning_of_day.to_i
      days_from_now = (seconds_from_now / (60 * 60 * 24)) + 1

      days_before = -2 * PREP_TIME_DAYS + 1
      duration = (rental.end_date.to_i - rental.start_date.to_i) / (3600 * 24)
      days_after = duration + 2 * PREP_TIME_DAYS - 1

      (days_before..days_after).each do |d|
        idx = days_from_now + d
        next unless idx >= 0 && idx < year.length
        year[idx][:available] = false
      end
    end

    year
  end

  def start_date_before_end_date
    if start_date && end_date && start_date >= end_date
      errors.add(:start_date, "must be before end date")
    end
  end

  def dates_are_available
    return unless start_date && end_date
    errors.add(:start_date, "is unavailable") unless
      Rental.are_dates_available?(start_date, end_date, printer_id, id)
  end

end
