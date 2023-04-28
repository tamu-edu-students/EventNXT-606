class GuestsController < ApplicationController  
  require 'net/http'
  require 'json'

  def index
    @guests = Guest.all
    @event = Event.find(params[:event_id])
    @guests = @event.guests
  end

  def new_guest
    @guests_import = GuestsImport.new
    render 'guests/newimport'
  end

  def import
  # Get event ID and API key from user input
  event_id = params[:guests_import][:event_id]
  api_key = params[:guests_import][:api_key]

  # Set up API request
  uri = URI("https://app.ticketmaster.com/partners/v1/events/#{event_id}/#{api_key}")#/guestlist
  params = { 'apikey' => api_key }
  uri.query = URI.encode_www_form(params)
  response = Net::HTTP.get_response(uri)
  guest_list = JSON.parse(response.body)

  # Parse guest list and create Guest records
  guest_list['guests'].each do |guest_data|
    guest = Guest.new(
      first_name: guest_data['first_name'],
      last_name: guest_data['last_name'],
      email: guest_data['email'],
      seat_level: guest_data['seat_level'],
      number_of_seats: guest_data['number_of_seats'],
      event_id: guest_data['event_id']
    )
    guest.save
  end

  redirect_to guests_path, notice: "Guest list imported successfully"
end

  
  def guests_import_params
    params.require(:guests_import).permit(:event_id, :api_key)
  end

  def send_email_invitation
    #new
    #new text
    event = Event.find(params[:event_id])
    @guest = Guest.find(params[:id])
    if @guest.booking_status == 'Yes' or @guest.booking_status == 'No'
      flash[:notice] = "The guest #{@guest.first_name} #{@guest.last_name} has already confirmed this invitation."
      redirect_to event_path(event) and return
    end
    puts("Hash Params listed here! ###################")
    puts($event_date)
    puts("Hash Params above! ###################")
    
    GuestMailer.rsvp_invitation_email(event, @guest).deliver_now
    GuestMailer.referral_email(event, @guest).deliver_now
		#end of mail module
    @guest.update({:booking_status => 'Invited', :total_booked_num => 0})
    # Guest.update!(params[:id], booking_status: 'Invited')
    flash[:notice] = "The email was successfully sent to #{@guest.first_name} #{@guest.last_name}."
    redirect_to event_path(event)
  end
  
  def update_in_place
    event = Event.find(params[:event_id])
    guest = Guest.find(params[:id])
  
    respond_to do |format|
      if guest.update(guest_params)
        format.html { redirect_to(event_guest_path(event, guest), :notice => 'Guest was successfully updated.') }
        format.json { respond_with_bip(guest) }
      else
        format.html { redirect_to(event_guest_path(event, guest), :notice => 'Guest was not successfully updated.') }
        format.json { respond_with_bip(guest) }
      end
    end
  end

  def new
    @event = Event.find(params[:event_id])
    @seats = Seat.where(event_id: params[:event_id])
    @guest = Guest.new
  end
    
  def create
    @guest = Guest.new(guest_params)
    @guest.invited_at = Time.now
    @guest.invite_expiration = (Time.now + (2*7*24*60*60)) # probably change elsewhere
    @guest.referral_expiration = (Time.now + (2*7*24*60*60)) # probably change elsewhere
    #render json: {guest: guest, guest_params: guest_params}
    if @guest.save!
      @event = Event.find(@guest.event_id)
      GuestMailer.rsvp_invitation_email(@event, @guest).deliver_now
      redirect_to @event
    end
  end
  
  def edit
    @event = Event.find(params[:event_id])
    @guest = Guest.find(params[:id])
    if @guest.booking_status == 'Yes' or @guest.booking_status == 'No'
      render :template => "guests/success_confirmation"
    end
  end


  def update
    # VIP guest updates RSVP information (Other infos updated by event owner is handled by update_in_place)
    event = Event.find(params[:event_id])
    guest = Guest.find(params[:id])
    
    if params[:guest][:booking_status] == 'Yes' and params[:guest][:total_booked_num] == '0'
      flash[:notice] = "Please select the ticket number to be greater than 0 for the 'Yes' choice"
      redirect_to edit_event_guest_path(event, guest) and return
    end
    if params[:guest][:booking_status] == 'No' and params[:guest][:total_booked_num] != '0'
      flash[:notice] = "Please select the ticket number to be 0 for the 'No' choice"
      redirect_to edit_event_guest_path(event, guest) and return
    end
    
    if guest.update(guest_params)
      if guest.total_booked_num > 0
				GuestMailer.rsvp_confirmation_email(event, guest).deliver
			end
      render :template => "guests/success_confirmation"
    else
      render file: "#{Rails.root}/public/500.html", layout: false
    end
  end
  
  def delete
    
  end

  def destroy
    event = Event.find(params[:event_id])
    guest = event.guests.find(params[:id])
    guest.destroy
    
    # @event.total_seats_guest -= 1
    # @event.balance += 1
    # @event.update({:total_seats_guest => @event.total_seats_guest, :balance => @event.balance})
    redirect_to event_path(event)
  end



  def show_qr 
    @guest = Guest.find(params[:id])
    @qr_code_svg = QrCodeService.generate_qr_code(@guest)
  end
  
  # def destroy_all
  #   @event = Event.find(params[:event_id])
  #   @guests = @event.guests
  #   @guests.destroy
    
  #   # @event.total_seats_guest -= 1
  #   # @event.balance += 1
  #   # @event.update({:total_seats_guest => @event.total_seats_guest, :balance => @event.balance})
  #   redirect_to event_path(@event)
  # end
  
  private
    def guest_params
      #params.require(:guest).permit(:first_name, :last_name, :event_id, :email_address, :affiliation, 
      params.permit(:first_name, :last_name, :event_id, :email, :affiliation, :perks, :comments,
        :added_by, :type, :category, :max_seats_num, :booked, :total_booked_num)
    end
    
end

