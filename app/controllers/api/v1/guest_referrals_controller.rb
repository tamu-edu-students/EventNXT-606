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
    referral.guest_id = @guest.id
    referral.event = params[:event_id]
    referral.email = params[:email]
    
    referred_guest = GuestReferral.find_by(event: params[:event_id], email: params[:email])
    
    if(not referred_guest)
      referral.save
    end
    
    head :ok
    
    #@event = Event.find(@guest.event_id)
    #GuestMailer.purchase_tickets_email(referral.email, @event, @guest).deliver_now
    #redirect_to @event
    #else
    #render json: referral.errors(), status: :unprocessable_entity
    #end
    
    senders = @guest
    @reciever = params[:email]

    template = EmailTemplate.where(name: "Purchase Tickets", event_id: params[:event_id], user_id: @guest.added_by)
    
    template = EmailTemplate.find(template.ids[0])

    # note: attachments are tempfiles here
    attachments = template.attachments.map { |attachment|
      [attachment.original_filename.to_s, File.read(attachment.tempfile)]
    }.to_h unless template.attachments.nil?

    # render an email from template for each guest
    subject = template.subject
    subject = Mustache.render(subject, event: @event, guest: @guest)

    purchase_url = "#{request.base_url}/events/#{@event.id}/purchase?token=#{@guest.id}&referee=#{@reciever}"

    body = ''
    ActiveStorage::Current.set(host: request.base_url) do
      body = Mustache.render(template.body,
        sender: senders[0],
        event: @event,
        purchase_url: purchase_url)
    end

    if template.is_html
      body = Rails::Html::SafeListSanitizer.new.sanitize(body)
      plain = Rails::Html::SafeListSanitizer.new.sanitize(
        body, tags: %w(a img strong em b i u s table tr td ))
    end
    
    #Generic mailer mod
    from = senders.email
    attachments.each { |filename, file| attachments[filename] = file } unless attachments.nil?

    GuestMailer.purchase_tickets_email(from, params[:email], subject, body).deliver_now

  end
  
  private
end
