class Printer
  attr_reader :name, :priority, :id

  def self.all
    [
      {id: 0, name: "Ultimaker II", priority: 0},
      {id: 1, name: "Lulzbot Mini", priority: 1}
    ].map{|p| Printer.new(p[:id], p[:name], p[:priority])}
  end

  def initialize(id, name, priority)
    @id = id
    @name = name
    @priority = priority
  end

end
