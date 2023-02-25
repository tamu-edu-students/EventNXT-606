require "rails_helper"

RSpec.describe Api::V1::BoxofficeHeadersController, type: :controller do
    describe 'GET #index' do
      let!(:event) { create(:event) }
      let!(:header1) { create(:boxoffice_header, event_id: event.id) }
      let!(:header2) { create(:boxoffice_header, event_id: event.id) }
  
      it 'returns a successful response' do
        get :index, params: { event_id: event.id }
        expect(response).to be_successful
      end
  
      it 'returns the headers for the specified event' do
        get :index, params: { event_id: event.id }
        expect(JSON.parse(response.body)).to eq([header1.as_json, header2.as_json])
      end
    end
  end
  