class EventsController < ApplicationController
  def index
    #@events = Event.all
    @events = Event.where(user_id: 64) # hardcoded needs to be as some type of param
  end

  def show
    @event = Event.find(params[:id])
    @event_id = params[:id]
    @seats = Seat.where(event_id: params[:id])
    @guests = Guest.where(event_id: params[:id])
    # @res = Seat.left_joins(:guest_seat_tickets, :guests)
    #           .joins("LEFT JOIN boxoffice_seats ON boxoffice_seats.seat_section = seats.category")
    #           .select('seats.category,price,total_count,'\
    #                   'sum(coalesce(committed,0)) as total_committed,'\
    #                   'sum(coalesce(allotted,0)) as total_allotted,'\
    #                   'total_count - sum(coalesce(committed,0)) - sum(coalesce(boxoffice_seats.booked_count,0)) as remaining,'\
    #                   'count(*) filter(where "booked") as total_booked,'\
    #                   'count(*) filter (where not "booked") as total_not_booked,'\
    #                   'count(distinct(guest_id)) filter(where "allotted" > 0) as total_guests ,'\
    #                   'sum(coalesce(committed,0)) * price as balance, '\
    #                   'sum(coalesce(boxoffice_seats.booked_count,0)) as boxoffice_booked')
    #           .group('seats.id')
    #           .where(seats: {event_id: @event.id}, boxoffice_seats: {event_id: @event.id})
    
    #added for tentative remaining seats - SP
    @res = Seat.left_joins(:guest_seat_tickets, :guests)
              .joins("LEFT JOIN boxoffice_seats ON boxoffice_seats.seat_section = seats.category")
              .select('seats.category,price,total_count,'\
                      'sum(coalesce(committed,0)) as total_committed,'\
                      'sum(coalesce(allotted,0)) as total_allotted,'\
                      'total_count - sum(coalesce(committed,0)) - sum(coalesce(boxoffice_seats.booked_count,0)) as remaining,'\
                      'total_count - sum(coalesce(allotted,0)) - sum(coalesce(boxoffice_seats.booked_count,0)) as tentative_remaining,'\
                      'count(*) filter(where "booked") as total_booked,'\
                      'count(*) filter (where not "booked") as total_not_booked,'\
                      'count(distinct(guest_id)) filter(where "allotted" > 0) as total_guests ,'\
                      'sum(coalesce(committed,0)) * price as balance, '\
                      'sum(coalesce(boxoffice_seats.booked_count,0)) as boxoffice_booked')
              .group('seats.id')
              .where(seats: {event_id: @event.id}, boxoffice_seats: {event_id: @event.id})
    
    @boxoffice_seats = BoxofficeSeat.where(event_id: params[:id])
  end

  def new
    @event = Event.new
  end

  def create
    par = event_params.to_h
    if doorkeeper_token
      par[:user_id] = doorkeeper_token[:resource_owner_id]
    else
      par[:user_id] = warden.authenticate(scope: :public)
    end
    @event = Event.new(par)

    #render json: {event: event}
    if @event.save
      redirect_to @event
    end
    #render_valid(event)
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])

    if @event.update(event_params)
      redirect_to @event
    else
      render :edit
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    redirect_to root_path
  end

  def import_new_spreadsheet
    if !params[:file]
      redirect_to root_path
    end
    
    @event = Event.import(params[:file])
    redirect_to @event
  end

  def summary
    res = GuestSeatTicket.joins(:seat, :guest)
              .select('category,price,total_count,'\
                      'sum(committed) as total_committed,'\
                      'sum(allotted) as total_allotted,'\
                      'total_count - sum(committed) as remaining,'\
                      'count(*) filter(where "booked") as total_booked,'\
                      'count(*) filter (where not "booked") as total_not_booked,'\
                      'count(distinct(guest_id)) filter(where "allotted" > 0) as total_guests ,'\
                      'sum(committed) * price as balance')
              .group('seats.id')
              .where(seats: {event_id: params[:event_id]})
    render json: res.to_json, except: [:id]
  end

  private
  def event_params
    params.permit(:title, :address, :datetime, :image, :description, :last_modified, :box_office, :user_id, :token)
  end

  def render_valid(event)
    @event = event
    if event.valid?
      event.image.attach(params[:image]) if params[:image].present?
      event.box_office.attach(params[:image]) if params[:box_office].present?
      #head :ok
      #render json: {event: event, params: params}
      params[:id] = event.id
      @event
    else
      render json: {errors: event.errors.full_messages}, status: :unprocessable_entity
    end
  end
end
