require 'rails_helper'

RSpec.describe BooksController, type: :controller do
    describe "GET #show" do
      let(:event_id) { 123 }
      let(:token) { "abc123" }
      
      context "when a valid token is provided" do
        before do
          get :show, params: { event_id: event_id, token: token }
        end
        
        it "returns a successful response" do
          expect(response).to be_successful
        end
        
        it "renders the show template" do
          expect(response).to render_template(:show)
        end
        
        it "assigns the correct instance variables" do
          expect(assigns(:event_id)).to eq(event_id)
          expect(assigns(:token)).to eq(token)
        end
      end
      
      context "when no token is provided" do
        before do
          get :show, params: { event_id: event_id }
        end
        
        it "returns a not found response" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
  