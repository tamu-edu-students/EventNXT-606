class Api::V1::EventsController < Api::V1::ApiController
  def index
    render json: {message: 'No bearer token'}, status: :forbidden and return unless current_user
    events = Event.where(user_id: current_user.id).limit(params[:limit]).offset(params[:offset])
    render json: events.map{ |event|
      with_attachments(event)
    }
  end

  def show
    @event = Event.find(params[:id])
    render json: {event: @event}
  end

  def create
    render json: {message: 'No bearer token'}, status: :forbidden and return unless current_user
    par = event_params.to_h
    par[:user_id] = current_user.id
    event = Event.create(par)
    render_valid(event)
    if event.valid?
      event.save
      create_default_templates(event)
      render json: with_attachments(event)
    else
      render json: {errors: event.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def headers
    event = Event.find params[:event_id]
    header = params[:id]
    event.box_office.open do |file|
      sheet = Roo::Spreadsheet.open(file.path)
      sheet.each_with_index do |row, idx|
        if idx+1 == header.to_i
          render json: {row: row}
          break
        end
      end
    end
  end

  def dataload
    event = Event.find params[:event_id]
    header = params[:header].to_i
    firstName = params[:firstName].to_i
    lastName = params[:lastName].to_i
    email = params[:email].to_i
    seatLevel = params[:seatLevel].to_i
    seats = params[:seats].to_i

    event.boxoffice_headers&.destroy
    event.boxoffice_seats.delete_all
    boxofficeHeaders = BoxofficeHeaders.new(:event_id => event.id, 
      :header_row => header,
      :first_name => firstName,
      :last_name => lastName,
      :email => email,
      :seat_section => seatLevel,
      :tickets => seats)
    boxofficeHeaders.save!

    event.sale_tickets.delete_all
    summary = {}
    event.box_office.open do |file|
      sheet = Roo::Spreadsheet.open(file.path)
      sheet.each_with_index do |row, idx|
        next if idx < header.to_i
        next if row[email] == " "
        if !row[seatLevel].nil? and !row[seatLevel].empty? and !row[seats].nil?
          summary.store(row[seatLevel], 
            summary.key?(row[seatLevel]) ? row[seats] + summary[row[seatLevel]] : row[seats])
        end
        saleTicket = SaleTicket.new(:event_id => event.id, 
          :user_id => current_user.id,
          :first_name => row[firstName],
          :last_name => row[lastName],
          :email => row[email],
          :seat_section => row[seatLevel],
          :tickets => row[seats])
        saleTicket.save!
        
        referral = GuestReferral.find_by(event: event.id, email: row[email])
        puts referral.to_json
        if(referral)
          referral.update(:counted => row[seats])
        end
      end
    end
    summary.each do |section, count|
      boxofficeSeat = BoxofficeSeat.new(:event_id => event.id, 
        :seat_section => section,
        :booked_count => count)
      boxofficeSeat.save!
    end
    
    # load seat categories from boxoffice file and display them in manage seating categories. - SP
    summary.each do |section, count|
      existing_seat = Seat.find_by(event_id: event.id, category: section)
      if existing_seat.nil?
        copy_seats = Seat.new(event_id: event.id, category: section, total_count: 0)
        copy_seats.save!
      end
    end
  end

  def update
    event = Event.find params[:id]
    #update_referral_count event
    remove_box_office_data event
    event.update(event_params)
    if event.valid?
      event.save
      render json: with_attachments(event)
    else
      puts "Not working"
      render json: {errors: event.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    event = Event.find params[:id]

    if params.has_key? :image
      event.image.purge if event.image.attached?
    end

    if params.has_key? :box_office
      event.box_office.purge if event.box_office.attached?
    end

    unless params.has_key? :partial
      unless event.destroy
        render json: event.errors, status: :unprocessable_entity
        return
      end
    end

    head :ok
  end

  def summary
    res = Seat.left_joins(:guest_seat_tickets, :guests)
              .joins("LEFT JOIN boxoffice_seats ON boxoffice_seats.seat_section = seats.category")
              .select('seats.category,price,total_count,'\
                      'sum(coalesce(committed,0)) as total_committed,'\
                      'sum(coalesce(allotted,0)) as total_allotted,'\
                      'total_count - sum(coalesce(committed,0)) as remaining,'\
                      'count(*) filter(where "booked") as total_booked,'\
                      'count(*) filter (where not "booked") as total_not_booked,'\
                      'count(distinct(guest_id)) as total_guests,'\
                      'sum(coalesce(committed,0)) * price as balance')
              .group('seats.id')
              .where(seats: {event_id: @event.id}, boxoffice_seats: {event_id: @event.id})
    render json: res, except: [:id]
  end

  private

  def with_attachments(model)
    image_url = url_for(model.image) if model.image.attached?
    box_office_url = url_for(model.box_office) if model.box_office.attached?
    model.as_json.merge({ image_url: image_url, box_office_url: box_office_url })
  end

  def remove_box_office_data(event)
    return unless event_params.has_key? :box_office
    event = Event.find(event.id)
    event.sale_tickets.delete_all
    event.boxoffice_seats.delete_all
  end

  def update_referral_count(event)
    # updates the referral count after updating the box office data by looking for
    # the referred email
    return unless event_params.has_key? :box_office
    prior_emails = event.box_office.open do |file|
      sheet = Roo::Spreadsheet.open(file.path)
      sheet.each(email: 'Email').map { |row| row[:email] }.uniq
    end

    # todo: better to check if files have same content first?
    sheet = Roo::Spreadsheet.open(event_params[:box_office].tempfile.path)
    curr_emails = sheet.each(email: 'Email').map { |row| row[:email] }.uniq
    new_emails = prior_emails.nil? ? curr_emails : curr_emails - prior_emails
    return if new_emails.empty?

    converted_referrals = GuestReferral.select('guest_id, count(guest_id)')
                                       .where(email: new_emails, counted: false)
                                       .group(:guest_id)
    converted_referrals.each { |converted_referral|
      count = converted_referral.count
      guest = converted_referral.guest
      guest.guest_referral_rewards.update_all("count = count + #{count}")
    }
    GuestReferral.where(email: new_emails).update(counted: true)
  end

  def create_default_templates(event)
    rsvp_template = EmailTemplate.new 
    rsvp_template.name = 'RSVP Invitation'
    rsvp_template.subject = '{{event.title}} - Invitation'
    rsvp_template.body = File.read(Rails.root.join('app', 'views', 'guest_mailer', 'rsvp_invitation_email.html'))
    rsvp_template.is_html = true
    rsvp_template.event_id = event.id
    rsvp_template.user_id = current_user.id

    confirmation_template = EmailTemplate.new 
    confirmation_template.name = 'RSVP Confirmation'
    confirmation_template.subject = '{{event.title}} - Confirmation'
    confirmation_template.body = File.read(Rails.root.join('app', 'views', 'guest_mailer', 'rsvp_confirmation_email.html'))
    confirmation_template.is_html = true
    confirmation_template.event_id = event.id
    confirmation_template.user_id = current_user.id

    rsvp_end_template = EmailTemplate.new 
    rsvp_end_template.name = 'RSVP Expired'
    rsvp_end_template.subject = '{{event.title}} - RSVP Expired'
    rsvp_end_template.body = File.read(Rails.root.join('app', 'views', 'guest_mailer', 'rsvp_end_email.html'))
    rsvp_end_template.is_html = true
    rsvp_end_template.event_id = event.id
    rsvp_end_template.user_id = current_user.id
    
    referral_template = EmailTemplate.new 
    referral_template.name = 'Referral Invitation'
    referral_template.subject = '{{event.title}} - Invitation'
    referral_template.body = File.read(Rails.root.join('app', 'views', 'guest_mailer', 'referral_invitation_email.html'))
    referral_template.is_html = true
    referral_template.event_id = event.id
    referral_template.user_id = current_user.id
    
    purchase_template = EmailTemplate.new 
    purchase_template.name = 'Purchase Tickets'
    purchase_template.subject = 'Purchase Tickets'
    purchase_template.body = File.read(Rails.root.join('app', 'views', 'guest_mailer', 'purchase_tickets_email.html'))
    purchase_template.is_html = true
    purchase_template.event_id = event.id
    purchase_template.user_id = current_user.id
    
    rsvp_template.save
    confirmation_template.save
    rsvp_end_template.save
    referral_template.save
    purchase_template.save
    
  end

  def event_params
    params.permit(:title, :address, :datetime, :image, :description, :box_office, :last_modified, :user_id, :id)
        #:image, :box_office, :x1, :y1, :x2, :y2, :user_id)
  end

  def render_valid(event)
  end
end
