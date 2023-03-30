class SeatingTypesController < ApplicationController
  before_action :set_seating_type, only: %i[ show edit update destroy ]

  # GET /seating_types or /seating_types.json
  def index
    @seating_types = Seat.all
  end

  # GET /seating_types/1 or /seating_types/1.json
  def show
  end

  # GET /seating_types/new
  def new
    @seating_type = Seat.new
  end

  # GET /seating_types/1/edit
  def edit
  end

  # POST /seating_types or /seating_types.json
  def create
    @event = Event.find(params[:event_id])
    @seating_type = Seat.new(seating_type_params)
    @seating_type.price = 21
    @seating_type.event_id = @event.id


    if @seating_type.save
      redirect_to event_path(@seating_type.event_id)
    else
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: @seating_type.errors, status: :unprocessable_entity }
      end
  end

  # PATCH/PUT /seating_types/1 or /seating_types/1.json
  def update
    rem_seats = seating_type_params[:total_seat_count].to_i - seating_type_params[:vip_seat_count].to_i - seating_type_params[:box_office_seat_count].to_i
    respond_to do |format|
      if @seating_type.update(seating_type_params)
        @seating_type.update({:balance_seats => rem_seats})
        format.html { redirect_to @seating_type, notice: "Seating type was successfully updated." }
        format.json { render :show, status: :ok, location: @seating_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @seating_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /seating_types/1 or /seating_types/1.json
  def destroy
    @event_ref = @seating_type.event.id
    @seating_type.destroy
    respond_to do |format|
      format.html { redirect_to @seating_type, notice: "Seating type was successfully destroyed.", flash: {event_ref: @event_ref} }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_seating_type
      @seating_type = Seat.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def seating_type_params
      # params.permit(:category, :total_count, :event_id, :price)
      params.require(:seat).permit(:category, :total_count)

    end
end
