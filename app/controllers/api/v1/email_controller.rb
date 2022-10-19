class Api::V1::EmailController < Api::V1::ApiController
  include Api::V1::EmailHelper

  def bulk
    senders = User.where(email: params[:senders]).collect.to_a
    recipientsList = (params[:recipients][0]).split(';').collect.to_a
    guests = []
    for recipient in recipientsList do
      guest = Guest.where(event_id: params[:event_id], email: recipient).collect.to_a
      guests.push(guest.first)
    end
    guests.collect.to_a
    
    template = EmailTemplate.find(params[:template_id]) unless params[:template_id].blank?

    # note: attachments are tempfiles here
    attachments = params[:attachments].map { |attachment|
      [attachment.original_filename.to_s, File.read(attachment.tempfile)]
    }.to_h unless params[:attachments].nil?

    unless template.nil?
      outbox = bulk_email_from_template(
        senders, guests, template, attachments: attachments)
    else
      outbox = bulk_email(senders, guests, params[:subject], params[:body], attachments: attachments)
    end

    outbox.each { |mail| mail.deliver_later }
    guests.each{|guest| guest.update({ emailed_at: Time.now }) }

    render json: guests, only: [:email]
  end

  def create
    # prototype functionality: to field is default email while senders are cc'd
    # ideally to field is user email and cc is specified by user
    senders = User.where(email: params[:senders]).collect.to_a
    guests = !params[:all_from].nil? ? Guest.where(event_id: params[:all_from])
                                     : Guest.where(event_id: params[:event_id], email: params[:recipients])
    guests.update_all({ emailed_at: Time.now })
    guests = guests.collect.to_a

    template = EmailTemplate.find(params[:template_id]) unless params[:template_id].blank?

    # note: attachments are tempfiles here
    attachments = params[:attachments].map { |attachment|
      [attachment.original_filename.to_s, File.read(attachment.tempfile)]
    }.to_h unless params[:attachments].nil?

    unless template.nil?
      outbox = gen_email_from_template(
        senders, guests, template, attachments: attachments)
    else
      outbox = gen_email(
        senders, guests, params[:subject], params[:body], attachments: attachments)
    end
    outbox.each { |mail| mail.deliver_later }

    render json: guests, only: [:email]
  end

  private
end
