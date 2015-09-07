require 'spec_helper'

describe Printer do

  describe 'all' do

    it 'lists all printers' do
      printers = Printer.all
      expect(printers.length).to eq(3)

      printer_a = printers[0]
      expect(printer_a.id).to eq(0)
      expect(printer_a.name).to eq("Ultimaker II")
      expect(printer_a.priority).to eq(2)
      expect(printer_a.inventory).to eq(1)

      printer_b = printers[1]
      expect(printer_b.id).to eq(1)
      expect(printer_b.name).to eq("Lulzbot Mini")
      expect(printer_b.priority).to eq(1)
      expect(printer_b.inventory).to eq(1)

      printer_c = printers[2]
      expect(printer_c.id).to eq(2)
      expect(printer_c.name).to eq("Printrbot Simple Metal")
      expect(printer_c.priority).to eq(0)
      expect(printer_c.inventory).to eq(6)

    end

  end

  describe 'find_by_id' do

    it 'finds a printer by id' do
      printer = Printer.find_by_id(1)
      expect(printer.id).to eq(1)
    end

    it 'returns nil if not found' do
      expect(Printer.find_by_id(100)).to be_nil
    end

  end

end
