class SeatsController < ApplicationController
    before_action :set_seat, only: [:show, :edit, :update, :destroy]
  
    def index
      @seats = Seat.all
    end
  
    def show
    end
  
    def new
      @seat = Seat.new
    end
  
    def edit
    end
  
    def create
      @seat = Seat.new(seat_params)
  
      respond_to do |format|
        if @seat.save
          format.html { redirect_to @seat, notice: 'Seating type was successfully created.' }
        else
          format.html { render :new }
        end
      end
    end
  
    def update
      @seat.update(seat_params)
      respond_to do |format|
        format.html { redirect_back(fallback_location: @event) }
      end
    end
  
    def destroy
      @seat.destroy
      respond_to do |format|
        format.html { redirect_back(fallback_location: @event) }
      end
    end
  
    private
  
    def set_seat
      @seat = Seat.find(params[:id])
    end
  
    def seat_params
      params.require(:seat).permit(:category, :total_count)
    end
  end