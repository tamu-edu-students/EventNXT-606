require "rails_helper"

RSpec.describe EmailHelper, type: :helper do 
    describe "gen_email" do #iteration 2 added Spring 2023
        let!(:sender) {sender.create("senderhelper@gmail.com")}
        let!(:recipients) {recipients.create("receiverhelper@gmail.com")}
        let!(:subject) {subject.create("A Subject Title")}
        let!(:body) {body.create("This is a sentence in the body of the email.")}
        let!(:opts) {obj.create(nil)}
        
        it "renders correctly" do 
        expect(mail.sender).to eq("senderhelper@gmail.com")
        expect(mail.recipients).to eq("receiverhelper@gmail.com")
        expect(mail.subject).to eq("A Subject Title")
        expect(mail.body).to eq("This is a sentence in the body of the email.")
        expect(mail.opts).to eq(nil)
        end 
    end 
    
    describe "bulk_email" do 
        let!(:sender) {sender.create("helper@gmail.com")} 
        let!(:recipients) {recipients.create("helper2@gmail.com")}
        let!(:subject) {subject.create("Something")}
        let!(:body) {body.create("This is a sentence in the body of the email.")}
        let!(:opts){obj.create(nil)}
     
     it "renders correctly" do 
        expect(mail.sender).to eq("helper@gmail.com")
        expect(mail.recipients).to eq("helper2@gmail.com")
        expect(mail.subject).to eq("Something")
        expect(mail.body).to eq("This is a sentence in the body of the email.")
        expect(mail.opts).to eq(nil)
     end     
        
        
        
        
    end 
    
    describe "bulk_email_from_template" do 
        let!(:sender) {sender.create("senderhelper@gmail.com")}
        #guests
        #template 
        let!(:opts) {obj.create(nil)}
    it "renders correctly" do 
        
        
        
        
    end 
        
        
    end 
    
    describe "gen_email_from_template" do 
        
        
    end 
    
    
    
    
    
end 
