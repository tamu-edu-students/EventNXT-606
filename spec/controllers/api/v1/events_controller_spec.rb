require 'rails_helper'

RSpec.describe Api::V1::EventsController, type: :controller do
  describe "GET #show" do
      let(:event) { create(:event) }
      let(:id) { event.id }
      
      before do
        get :show, params: { id: id }
      end
      
      it "returns the event" do
        expect(JSON.parse(response.body)['event']['id']).to eq(id)
      end
    end
end
