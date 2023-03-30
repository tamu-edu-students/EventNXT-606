require 'rails_helper'

RSpec.describe Api::V1::SaleTicketsController, type: :controller do
  describe "GET #index" do
    let(:event_id) { 123 }
    let(:limit) { 10 }
    let(:offset) { 5 }
    
    before do
      create_list(:sale_ticket, 15, event_id: event_id)
    end
    
    context "when limit and offset parameters are provided" do
      before do
        get :index, params: { event_id: event_id, limit: limit, offset: offset }
      end
      
      it "returns a successful response" do
        expect(response).to be_successful
      end
      
      it "returns the correct number of sales" do
        expect(json_response.size).to eq(limit)
      end
      
      it "returns the correct sales data" do
        expect(json_response[0]).to include(
          "id" => SaleTicket.first.id,
          "event_id" => event_id
        )
      end
    end
    
    context "when limit and offset parameters are not provided" do
      before do
        get :index, params: { event_id: event_id }
      end
      
      it "returns a successful response" do
        expect(response).to be_successful
      end
      
      it "returns all sales for the event" do
        expect(json_response.size).to eq(SaleTicket.where(event_id: event_id).count)
      end
    end
  end
  
  describe "GET #count_all" do
    let(:event_id) { 123 }
    
    before do
      create_list(:sale_ticket, 5, event_id: event_id)
    end
    
    it "returns the correct count of sale tickets" do
      get :count_all, params: { event_id: event_id }
      expect(json_response).to eq(5)
    end
  end
end
