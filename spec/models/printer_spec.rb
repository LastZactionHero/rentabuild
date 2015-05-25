require 'spec_helper'

describe Printer do

  describe 'all' do

    it 'lists all printers' do
      printers = Printer.all
      expect(printers.length).to eq(2)

      printer_a = printers[0]
      expect(printer_a.id).to eq(0)
      expect(printer_a.name).to eq("Ultimaker II")
      expect(printer_a.priority).to eq(0)

      printer_b = printers[1]
      expect(printer_b.id).to eq(1)
      expect(printer_b.name).to eq("Lulzbot Mini")
      expect(printer_b.priority).to eq(1)
    end

  end

end
