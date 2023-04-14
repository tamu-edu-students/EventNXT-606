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
    '''referral = GuestReferral.find_by(guest_id: params[:token], event: params[:event_id], email: params[:referee])
    count = referral.counted
    puts count, params[:tickets]

    if referral.update(:counted => 1)
      puts "Count"
      puts referral.counted
      head :ok
    else
      #render json: referral.errors(), status: :unprocessable_entity
    end'''
    
    referral = GuestReferral.new 
    referral.guest = @guest
    referral.guest_id = @guest.id
    referral.event = params[:event_id]
    referral.email = params[:referee]
    
    referred_guest = GuestReferral.find_by(event: params[:event_id], email: params[:referee])
    
    if(not referred_guest)
      referral.save
    end
    head :ok
    
  end
  
end
