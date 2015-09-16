class Printer
  attr_reader :name, :priority, :id, :inventory, :prices

  class InvalidDurationError < StandardError
  end

  def self.all
    [
      {
        id: 0,
        name: "Ultimaker II",
        priority: 2,
        inventory: 1,
        prices: {
          7  => 300.00,
          14 => 400.00,
          21 => 450.00,
          30 => 500.00
        }
      },
      {
        id: 1,
        name: "Lulzbot Mini",
        priority: 1,
        inventory: 1,
        prices: {
          7  => 150.00,
          14 => 250.00,
          21 => 350.00,
          30 => 400.00
        }
      },
      {
        id: 2,
        name: "Printrbot Simple Metal",
        priority: 0,
        inventory: 5,
        prices: {
          7  => 120.00,
          14 => 240.00,
          21 => 300.00,
          30 => 350.00
        }
      }
    ].map{|p| Printer.new(
      p[:id],
      p[:name],
      p[:priority],
      p[:inventory],
      p[:prices])}
  end

  def self.find_by_name(name)
    Printer.all.select{|p| p.name == name}.first
  end

  def self.find_by_id(id)
    Printer.all.select{|p| p.id == id.to_i}.first
  end

  def initialize(id, name, priority, inventory, prices)
    @id = id
    @name = name
    @priority = priority
    @inventory = inventory
    @prices = prices
  end

  def price_for_duration(duration)
    raise InvalidDurationError unless @prices[duration]
    @prices[duration]
  end

end
