class Api::V1::GuestsController < Api::V1::ApiController
  include Api::V1::EmailHelper

  def index
    guests = Guest.where(event_id: params[:event_id]).limit(params[:limit]).offset(params[:offset])
    if params.has_key? :download
      event_title = Event.find(params[:event_id]).title.gsub ' ', '_'
      filename = "#{event_title}-guests-#{Time.now.strftime('%Y%m%d-%H%M%S')}.csv"
      send_data guests.to_csv, type: 'text/csv', filename: filename
      return
    end

    # render the results with ticket allotments merged in
    render json: guests.map {|guest|
      guest.as_json.merge({allotments: guest.guest_seat_tickets.as_json});
    }
  end

  def show
    guest = Guest.find(params[:id])
    if guest
      render json: guest
    else
      render json: guest.errors(), status: :not_found
    end
  end
  
  def invite
    guest = Guest.find(params[:id])
    if guest.booked and !params.has_key? :resend
      res = {:message => "#{guest.first_name} #{guest.last_name} has already confirmed this invitation."}
      render json: res
      return
    end
    
    # GuestMailer.rsvp_invitation_email(guest.event, guest).deliver_now
    template = EmailTemplate.where(name: "RSVP Invitation").first
    gen_email_from_template([current_user.email], guest.email, template)
    if guest.update({:invited_at => Time.now})
      head :ok
    else
      render json: guest.errors(), status: :unprocessable_entity
    end
    template = EmailTemplate.where(name: "Referral Invitation").first
    gen_email_from_template([current_user.email], guest.email, template)
    if guest.update({:invited_at => Time.now})
      head :ok
    else
      render json: guest.errors(), status: :unprocessable_entity
    end
  end
   

  def count_all
    count = Guest.where(event_id: params[:event_id]).count
    render json: count
  end
  
  def sum_all
    sum = GuestSeatTicket.where(guest_id: params[:id]).sum(:allotted)
    render json: sum
  end
  
  
  def mail
    sendmail = current_user
    render json: sendmail
  end
  
  
  def countmail
    @event = Event.find(params[:event_id])
    @guest = Guest.find(params[:id])

    GuestMailer.rsvp_guest_count_email(@event, @guest).deliver_now
    render json: @event
    
  end



  def updateguestcommitted
    guest = Guest.find(params[:id])
    if guest.update({:guestcommitted => params[:sumofall]})
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def book
    guest = Guest.find(params[:id])

    guest.update_attribute :booked, params[:accept].present?
    guest.reload

    if !guest.booked
      head :ok
      return
    end

    event = Event.find(params[:event_id])
    committments = params['seat_id'].zip(params['committed'])
    logger.debug committments

    committments.each {|arr| 
      guest.guest_seat_tickets.where(guest_id: params[:id], seat_id: arr[0]).update_all(committed: arr[1])
    }

    template = EmailTemplate.where(name: "RSVP Confirmation", event_id: params[:event_id]).first
    outbox = gen_email_from_template([event.user], [guest], template)
    outbox.each { |mail| mail.deliver_later }
    head :ok
  end

  def checkin
    guest = Guest.find(params[:id])
    if guest.update({checked: true})
      head :ok
    else
      head :unprocessable_entity
    end
  end
  
  def set_expiry
    recipientsList = (params[:recipients][0]).split(';').collect.to_a
    guests = []
    for recipient in recipientsList do
      guest = Guest.where(event_id: params[:event_id], email: recipient).collect.to_a
      guests.push(guest.first)
    end
    guests.collect.to_a
    guests.each{|guest| guest.update({ invite_expiration: params[:expiry_datetime] }) }

    render json: guests, only: [:expiry]
  end

  def get_expired
    guest = Guest.find(params[:guest_id])
    expired = false
    if guest and guest.invite_expiration < Time.now
      expired = true
    end
    render json: expired
  end

  def create
    guest = Guest.new(guest_params_create)
    guest.save
    if guest.save
      render json: guest.to_json, status: :created
    else
      render json: guest.errors, status: :unprocessable_entity
    end
  end
  
  def update
    guest = Guest.find(params[:id])
    if guest.update(guest_params_update)
      render json: guest.to_json, status: :ok
    else
      render json: guest.errors, status: :unprocessable_entity
    end
  end
  
  def destroy
    guest = Guest.find(params[:id])
    guest.destroy
    head :ok 
  end
  
  private

  def guest_params_update
    params.permit(
      :email, :first_name, :last_name, :affiliation, :perks, :comments, :type, 
      :invite_expiration, :referral_expiration, :invited_at,
      :event_id, :checked)
  end

  def guest_params_create
    p = params.permit(
      :email, :first_name, :last_name, :affiliation, :perks, :comments, :type,
      :invite_expiration, :referral_expiration, :invited_at,
      :event_id).to_h
    p[:added_by] = current_user.id
    return p
  end
end
