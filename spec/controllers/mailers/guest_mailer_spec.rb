require "rails_helper"

RSpec.describe GuestMailer, type: :mailer do
  describe "rsvp_invitation_email" do
    let(:event) { create(:event) }
    let(:guest) { create(:guest) }
    let(:mail) { GuestMailer.rsvp_invitation_email(event, guest) }

    it "renders the headers" do
      expect(mail.subject).to eq("#{event.title} - Invitation")
      expect(mail.to).to eq([guest.email])
      expect(mail.from).to eq(["from@example.com"]) # Replace with your actual email
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(event.title)
      expect(mail.body.encoded).to match(guest.first_name)
      expect(mail.body.encoded).to match(guest.last_name)
    end
  end

  describe "referral_email" do # add iteration 2 spring 2023
    let(:event){create(:event)}
    let(:guest){create(:guest)}
    let(:mail){ GuestMailer.referral_email(event,guest)}
    it "renders the headers" do
      expect(mail.subject).to eq("#{event.title} - Invitation")
      expect(mail.to).to eq([guest.email])
      expect(mail.from).to eq(["from@example.com"]) 
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(event.title)
      expect(mail.body.encoded).to match(guest.first_name)
      expect(mail.body.encoded).to match(guest.last_name)
    end
    
  end

  describe "purchase_tickets_email" do #added iteration 2 spring 2023
    let(:event){create(:event)}
    let(:guest){create(:guest)}
    let(:mail){ GuestMailer.purchase_tickets_email(referral_email, event, guest)}
   
   it "renders the headers" do
      expect(mail.subject).to eq("#{event.title} - Purchase Tickets")
      expect(mail.to).to eq([guest.email])
      expect(mail.from).to eq(["from@example.com"])
    end
    it "renders the body" do
      expect(mail.body.encoded).to match(event.title)
      expect(mail.body.encoded).to match(guest.first_name)
      expect(mail.body.encoded).to match(guest.last_name)
    end
   
  end

  describe "rsvp_confirmation_email" do #added iteration 2 spring 2023
    let(:event){create(:event)}
    let(:guest){create(:guest)}
    let(:mail){ GuestMailer.rsvp_confirmation_email(event,guest)}
    it "renders the headers" do
      expect(mail.subject).to eq("#{event.title} - Seating Confirmation")
      expect(mail.to).to eq([guest.email])
      expect(mail.from).to eq(["from@example.com"]) 
    end
    it "renders the body" do
      expect(mail.body.encoded).to match(event.title)
      expect(mail.body.encoded).to match(guest.first_name)
      expect(mail.body.encoded).to match(guest.last_name)
    end
  end

  describe "rsvp_guest_count_email" do #added iteration 2 spring 2023
    let(:event){create(:event)}
    let(:guest){create(:guest)}
    let(:mail){ GuestMailer.rsvp_guest_count_email(event,guest)}
     it "renders the headers" do
      expect(mail.subject).to eq("#{event.title} - Request Confirmation")
      expect(mail.to).to eq([guest.email])
      expect(mail.from).to eq(["from@example.com"]) 
    end
    it "renders the body" do
      expect(mail.body.encoded).to match(event.title)
      expect(mail.body.encoded).to match(guest.first_name)
      expect(mail.body.encoded).to match(guest.last_name)
    end
  end
end
