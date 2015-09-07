class Printer
  attr_reader :name, :priority, :id, :inventory

  def self.all
    [
      {id: 0, name: "Ultimaker II", priority: 2, inventory: 1},
      {id: 1, name: "Lulzbot Mini", priority: 1, inventory: 1},
      {id: 2, name: "Printrbot Simple Metal", priority: 0, inventory: 6}
    ].map{|p| Printer.new(p[:id], p[:name], p[:priority], p[:inventory])}
  end

  def self.find_by_name(name)
    Printer.all.select{|p| p.name == name}.first
  end

  def self.find_by_id(id)
    Printer.all.select{|p| p.id == id.to_i}.first
  end

  def initialize(id, name, priority, inventory)
    @id = id
    @name = name
    @priority = priority
    @inventory = inventory
  end

end
