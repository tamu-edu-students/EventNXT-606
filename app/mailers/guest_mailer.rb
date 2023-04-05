class GuestMailer < ApplicationMailer
    
    def rsvp_invitation_email(event, guest)
        @event = event
        @guest = guest
        mail(to: @guest.email, subject: "#{@event.title} - Invitation")
    end
    
   def referral_email(event, guest)
        @event = event
        @guest = guest
        mail(to: @guest.email, subject: "#{@event.title} - Invitation")
   end
    
   #def purchase_tickets_email(referral_email, event, guest)
        #@event=event
        #@guest = guest
        #mail(to: referral_email, subject: "Purchase Tickets")
   #end
   
   def purchase_tickets_email(from, to, subject, body)
        mail(from: from,
                to: to,
                subject: subject
             ) do |format|
               format.html { render inline: body.html_safe }
             end
   end
    
   def rsvp_confirmation_email(event, guest)
        @event = event
        @guest = guest
        mail(to: @guest.email, subject: "#{@event.title} - Seating Confirmation")
   end
    
    
   def rsvp_guest_count_email(event, guest)
        @event = event
        @guest = guest
        mail(to: @guest.email, subject: "#{@event.title} - Request Confirmation", 
        body: "Hi #{@guest.first_name} #{guest.last_name}, 

        Your request to book #{@guest.guestcommitted} seats has been sent to the organizer.
        
        Thank you and have a great day!!!")
    end


end
