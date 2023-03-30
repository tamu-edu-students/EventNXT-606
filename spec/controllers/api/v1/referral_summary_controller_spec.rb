require 'rails_helper'

RSpec.describe Api::V1::ReferralSummaryController, type: :controller do
    describe 'GET index' do
    let(:event_id) { '123' }
    let(:limit) { 20 }
    let(:offset) { 10 }
    
    it 'returns a successful response' do
        get :index, params: { event_id: event_id, limit: limit, offset: offset }
        expect(response).to have_http_status(:success)
      end
      
      it 'queries the correct data' do
        expect(Guest).to receive(:joins).with(:guest_referrals).and_call_original
        expect(Guest).to receive(:select).with("guests.email, guests.first_name, guests.last_name, guest_referrals.email as referred_email, guest_referrals.counted as status").and_call_original
        expect(Guest).to receive(:where).with(event_id: event_id).and_call_original
        get :index, params: { event_id: event_id, limit: limit, offset: offset }
      end
      
      it 'renders the correct json format' do
        guest = Guest.new(email: 'example@example.com', first_name: 'John', last_name: 'Doe')
        guest_referral = GuestReferral.new(email: 'referral@example.com', counted: true)
        guest.guest_referrals << guest_referral
        allow_any_instance_of(Api::V1::ReferralSummaryController).to receive(:query).and_return([guest])
        get :index, params: { event_id: event_id, limit: limit, offset: offset }
        expect(response.body).to eq([{    email: 'example@example.com',    first_name: 'John',    last_name: 'Doe',    referred_email: 'referral@example.com',    status: true  }].to_json)
      end
    end
end

      