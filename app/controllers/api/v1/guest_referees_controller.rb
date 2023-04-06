class Api::V1::GuestRefereesController < Api::V1::ApiController
  def show
    render json: { message: "Must specify token parameter." }, status: :bad_request and return unless (params.has_key? :token)
    @guest = Guest.find_by(id: params[:token], event_id: params[:event_id])
    if @guest
      render
    else
      render json: { message: "Unknown token." }, status: :not_found
    end
  end

  def create
    @guest = Guest.find_by(id: params[:token], event_id: params[:event_id])
    @event = Event.find(@guest.event_id)
    referral = GuestReferral.find_by(guest_id: params[:token], event: params[:event_id], email: params[:referee])
    count = referral.counted
    puts count, params[:tickets]

    if referral.update(:counted => count+params[:tickets].to_i)
      puts "Count"
      puts referral.counted
      head :ok
    else
      #render json: referral.errors(), status: :unprocessable_entity
    end
  end
  
end
