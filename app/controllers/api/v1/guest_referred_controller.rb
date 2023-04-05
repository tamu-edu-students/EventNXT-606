class Api::V1::GuestReferralsController < Api::V1::ApiController
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
    referral = GuestReferral.new 
    referral.guest = @guest
    referral.email = params[:email]
    redirect_to @event

    #if referral.save
      #head :ok
      #@event = Event.find(@guest.event_id)
      #GuestMailer.purchase_tickets_email(referral.email, @event, @guest).deliver_now
      #redirect_to @event
    #else
      #render json: referral.errors(), status: :unprocessable_entity
    
  end
  
  private
end
