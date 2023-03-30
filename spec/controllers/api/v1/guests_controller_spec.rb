require 'rails_helper'

RSpec.describe GuestsController, type: :controller do
    let(:event) { FactoryBot.create(:event) }
    let(:guest) { FactoryBot.create(:guest, event: event) }
  
    describe "GET #send_email_invitation" do
      context "when guest is already confirmed" do
        before do
          guest.booking_status = "Yes"
          guest.save
          get :send_email_invitation, params: { event_id: event.id, id: guest.id }
        end
  
        it "redirects to event page" do
          expect(response).to redirect_to(event_path(event))
        end
  
        it "sets flash notice message" do
          expect(flash[:notice]).to eq("The guest #{guest.first_name} #{guest.last_name} has already confirmed this invitation.")
        end
      end
  
      context "when guest is not confirmed" do
        before do
          guest.booking_status = "Maybe"
          guest.save
          allow(GuestMailer).to receive(:rsvp_invitation_email).and_return(double(deliver_now: true))
          allow(GuestMailer).to receive(:referral_email).and_return(double(deliver_now: true))
          get :send_email_invitation, params: { event_id: event.id, id: guest.id }
        end
  
        it "sends invitation email to guest" do
          expect(GuestMailer).to have_received(:rsvp_invitation_email).with(event, guest)
        end
  
        it "sends referral email to guest" do
          expect(GuestMailer).to have_received(:referral_email).with(event, guest)
        end
  
        it "updates guest's booking status to Invited" do
          guest.reload
          expect(guest.booking_status).to eq("Invited")
        end
  
        it "sets flash notice message" do
          expect(flash[:notice]).to eq("The email was successfully sent to #{guest.first_name} #{guest.last_name}.")
        end
  
        it "redirects to event page" do
          expect(response).to redirect_to(event_path(event))
        end
      end
    end
  
    describe "PATCH #update_in_place" do
      let(:params) { { id: guest.id, event_id: event.id, guest: { first_name: "John" } } }
  
      context "when guest is successfully updated" do
        before do
          patch :update_in_place, params: params
        end
  
        it "redirects to guest page with notice message" do
          expect(response).to redirect_to(event_guest_path(event, guest))
          expect(flash[:notice]).to eq("Guest was successfully updated.")
        end
      end
  
      context "when guest is not successfully updated" do
        before do
          allow(guest).to receive(:update).and_return(false)
          patch :update_in_place, params: params
        end
  
        it "redirects to guest page with error message" do
          expect(response).to redirect_to(event_guest_path(event, guest))
          expect(flash[:notice]).to eq("Guest was not successfully updated.")
        end
      end
    end
  
    describe "GET #new" do
      before do
        get :new, params: { event_id: event.id }
      end
  
      it "assigns a new guest instance variable" do
        expect(assigns(:guest)).to be_a_new(Guest)
      end
  
      it "assigns event and seats instance variables" do
        expect(assigns(:event)).to eq(event)
        expect(assigns(:seats)).
      end
    end
end  end