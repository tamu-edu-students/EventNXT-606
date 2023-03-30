require "rails_helper"

RSpec.describe SeatingTypesController, type: :controller do
    let(:valid_attributes) {
      { category: 'Test category', total_count: 100, event_id: 1, price: 10 }
    }
  
    let(:invalid_attributes) {
      { category: '', total_count: '', event_id: '', price: '' }
    }
  
    describe "GET #index" do
      it "returns a success response" do
        Seat.create! valid_attributes
        get :index, params: {}
        expect(response).to be_successful
      end
    end
  
    describe "GET #show" do
      it "returns a success response" do
        seating_type = Seat.create! valid_attributes
        get :show, params: { id: seating_type.to_param }
        expect(response).to be_successful
      end
    end
  
    describe "GET #new" do
      it "returns a success response" do
        get :new, params: {}
        expect(response).to be_successful
      end
    end
  
    describe "GET #edit" do
      it "returns a success response" do
        seating_type = Seat.create! valid_attributes
        get :edit, params: { id: seating_type.to_param }
        expect(response).to be_successful
      end
    end
  
    describe "POST #create" do
      context "with valid params" do
        it "creates a new SeatingType" do
          expect {
            post :create, params: { category: 'Test category', total_count: 100, event_id: 1, price: 10 }
          }.to change(Seat, :count).by(1)
        end
  
        it "redirects to the event page" do
          post :create, params: { category: 'Test category', total_count: 100, event_id: 1, price: 10 }
          expect(response).to redirect_to(event_path(1))
        end
      end
  
      context "with invalid params" do
        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, params: { seating_type: invalid_attributes }
          expect(response).to be_successful
        end
      end
    end
  
    describe "PUT #update" do
      let(:new_attributes) {
        { category: 'New category', total_count: 50, vip_seat_count: 25, box_office_seat_count: 5, balance_seats: 20, event_id: 2 }
      }
  
      context "with valid params" do
        it "updates the requested seating_type" do
          seating_type = Seat.create! valid_attributes
          put :update, params: { id: seating_type.to_param, category: 'New category' }
          seating_type.reload
          expect(seating_type.category).to eq('New category')
        end
  
        it "updates the balance seats" do
          seating_type = Seat.create! valid_attributes
          put :update, params: { id: seating_type.to_param, total_count: 50, vip_seat_count: 25, box_office_seat_count: 5 }
          seating_type.reload
          expect(seating_type.balance_seats).to eq(20)
        end
  
        it "redirects to the seating_type" do
          seating_type = Seat.create! valid_attributes
          put :update, params: { id: seating_type.to_param, category: 'New category' }
          expect(response).to redirect_to(seating_type)
        end
    end

end
end