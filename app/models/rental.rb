class Rental < ActiveRecord::Base
  validates_presence_of :start_date
  validates_presence_of :end_date
  validate :start_date_before_end_date
  validate :dates_are_available

  PREP_TIME_DAYS = 4

  def self.rental_windows(start_date, end_date, minimum_days = 7)
    rentals = Rental.where("start_date > ? AND end_date < ?", 
      start_date - 2 * PREP_TIME_DAYS.days,
      end_date + 2 * PREP_TIME_DAYS.days).order("start_date ASC")

    # Find all available windows
    windows = []
    window_start = start_date
    rentals.each do |rental|
      window_end = rental.start_date - 2 * PREP_TIME_DAYS.days
      windows << {start_date: window_start, end_date: window_end}
      window_start = rental.end_date + 2 * PREP_TIME_DAYS.days
    end
    windows << {start_date: window_start, end_date: end_date}

    # Remove any windows less than the minimum duration
    min_seconds = minimum_days * 24 * 60 * 60
    windows.delete_if{|w| w[:end_date].to_i - w[:start_date].to_i < min_seconds}

    windows
  end

  def prep_start_date
    start_date - PREP_TIME_DAYS.days
  end

  def prep_end_date
    end_date + PREP_TIME_DAYS.days
  end

  def self.are_dates_available?(start_date, end_date, id = nil)
    other_rentals = Rental.where("start_date > ? AND start_date < ? OR end_date > ? AND end_date < ?",
      start_date - 2 * PREP_TIME_DAYS.days, end_date + 2 * PREP_TIME_DAYS.days,
      start_date - 2 * PREP_TIME_DAYS.days, end_date + 2 * PREP_TIME_DAYS.days
    )
    other_rentals = other_rentals.where("id != ?", id) if id
    other_rentals.empty?
  end

  private

  def start_date_before_end_date
    if start_date && end_date && start_date >= end_date
      errors.add(:start_date, "must be before end date")
    end
  end

  def dates_are_available
    return unless start_date && end_date
    errors.add(:start_date, "is unavailable") unless 
      Rental.are_dates_available?(start_date, end_date, id)
  end

end
