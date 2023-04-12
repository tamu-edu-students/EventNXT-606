class GuestsImport
  include ActiveModel::Model

  attr_accessor :event_id, :api_key

  validates :event_id, presence: true
  validates :api_key, presence: true

  def save
    return false unless valid?
    
    guest_list = retrieve_guest_list_from_ticketmaster
    guest_list['guests'].each do |guest_data|
      guest = Guest.new_guest(first_name: guest_data['first_name'], last_name: guest_data['last_name'], email: guest_data['email'], seat_level: guest_data['seat_level'], number_of_seats: guest_data['number_of_seats'], event_id: guest_data['event_id'])
      #guest = Guest.new_guest(name: guest_data['name'], email: guest_data['email'], ticket_type: guest_data['ticket_type'])
      guest.save
    end

    true
  end

  private

  def retrieve_guest_list_from_ticketmaster
    uri = URI("https://api.ticketmaster.com/discovery/v2/events/#{event_id}/guestlist")
    params = { 'apikey' => api_key }
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  end
end
