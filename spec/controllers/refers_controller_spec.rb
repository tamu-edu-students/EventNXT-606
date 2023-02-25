require 'rails_helper'

RSpec.describe RefersController, type: :controller do
    describe "GET #show" do
      let(:event) { create(:event) }
      let(:guest) { create(:guest, event: event) }
  
      context "with a valid token" do
        let(:referral_token) { create(:referral_token, guest: guest) }
  
        it "renders the show template" do
          get :show, params: { event_id: event.id, token: referral_token.token }
          expect(response).to render_template(:show)
        end
  
        it "assigns the event_id and token variables" do
          get :show, params: { event_id: event.id, token: referral_token.token }
          expect(assigns(:event_id)).to eq(event.id)
          expect(assigns(:token)).to eq(referral_token.token)
        end
      end
  
      context "with an invalid token" do
        it "renders the not found template" do
          get :show, params: { event_id: event.id, token: "invalid_token" }
          expect(response).to render_template(:not_found)
        end
      end
  
      context "with no token parameter" do
        it "renders the not found template" do
          get :show, params: { event_id: event.id }
          expect(response).to render_template(:not_found)
        end
      end
    end
  end
  