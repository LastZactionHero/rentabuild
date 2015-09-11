class PrintersController < ApplicationController

  def prices
    printer = Printer.find_by_id(params[:id])

    if printer
      render status: 200, json: printer.prices
    else
      render status: 404, json: {}
    end

  end

end
