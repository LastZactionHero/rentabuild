class Printer
  attr_reader :name, :priority, :id

  def self.all
    [
      {id: 0, name: "Ultimaker II", priority: 2},
      {id: 1, name: "Lulzbot Mini", priority: 1},
      {id: 2, name: "Printrbot Simple Metal", priority: 0}
    ].map{|p| Printer.new(p[:id], p[:name], p[:priority])}
  end

  def self.find_by_id(id)
    Printer.all.select{|p| p.id == id.to_i}.first
  end

  def initialize(id, name, priority)
    @id = id
    @name = name
    @priority = priority
  end

end
