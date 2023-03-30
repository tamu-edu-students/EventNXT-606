require "rails_helper"

RSpec.describe GenericMailer, type: :mailer do
    describe "bulkMailer" do 
        let!(:sender) {sender.create("johndoe@gmail.com")} 
        let!(:recipients) {recipients.create("jandoe@gmail.com")}
        let!(:subject) {subject.create("Something")}
        let!(:body) {body.create("This is a sentence in the body of the email.")}
        let!(:opts){obj.create(nil)}
        let(:mail){GenericMailer.bulkMailer(senders, recipients, subject, body, opts = {})}
     
     it "renders correctly" do 
        expect(mail.sender).to eq("johndoe@gmail.com")
        expect(mail.recipients).to eq("jandoe@gmail.com")
        expect(mail.subject).to eq("Something")
        expect(mail.body).to eq("This is a sentence in the body of the email.")
        expect(mail.opts).to eq(nil)
     end 
     
end


    describe "mailer" do #iteration 2 Spring 2023
        let!(:sender) {sender.create("sender@gmail.com")}
        let!(:recipients) {recipients.create("receiver@gmail.com")}
        let!(:subject) {subject.create("A Subject Title")}
        let!(:body) {body.create("This is a sentence in the body of the email.")}
        let!(:opts) {obj.create(nil)}
        let(:mail){GenericMailer.mailer(senders, recipients, subject, body, opts = {})}
        
    it "renders correctly" do
        expect(mail.sender).to eq("sender@gmail.com")
        expect(mail.recipients).to eq("receiver@gmail.com")
        expect(mail.subject).to eq("A Subject Title")
        expect(mail.body).to eq("This is a sentence in the body of the email.")
        expect(mail.opts).to eq(nil)
    end
end
    




end
