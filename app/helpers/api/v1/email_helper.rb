module Api::V1::EmailHelper
  def gen_email(senders, guests, subject, body, opts = {})
    guests.map { |guest|
      GenericMailer.mailer(
        senders, guest, subject, body, attachments: opts[:attachments])
    }
  end

  def bulk_email(senders, guests, subject, body, opts = {})
    guests.map { |guest|
      GenericMailer.bulkMailer(
        senders, guest, subject, body, attachments: opts[:attachments])
    }
  end

  def bulk_email_from_template(senders, guests, template, opts = {})
    links = if template.attachments.attached?
      OpenStruct.new template.attachments.map { |attachment|
        [attachment.filename.to_s.gsub(/[^0-9A-Za-z]/, '_'), url_for(attachment)]
      }.to_h
    end

    attachments = if template.attachments.attached?
      template.attachments.map { |attachment| [attachment.filename.to_s, attachment.download] }.to_h
    end

    unless opts[:attachments].nil?
      attachments = attachments.merge(opts[:attachments])
    end

    # render an email from template for each guest
    logger.debug guests
    guests.map { |guest|
      subject = opts[:subject].nil? ? template.subject : opts[:subject]
      subject = Mustache.render(subject, event: guest.event, guest: guest)

      tickets = guest.guest_seat_tickets.map { |ticket|
        {
         category: ticket.seat.category,
         committed: ticket.committed,
         allotted: ticket.allotted
        }
      }

      rsvp_url = "#{request.base_url}/events/#{guest.event.id}/book?token=#{guest.id}"
      refer_url = "#{request.base_url}/events/#{guest.event.id}/refer?token=#{guest.id}"

      body = ''
      ActiveStorage::Current.set(host: request.base_url) do
        body = Mustache.render(template.body,
          sender: senders[0],
          event: guest.event,
          guest: guest,
          tickets: tickets,
          referral_rewards: guest.event.referral_rewards,
          rsvp_url: rsvp_url,
          refer_url: refer_url,
          links: links)
      end

      if template.is_html
        body = Rails::Html::SafeListSanitizer.new.sanitize(body)
        plain = Rails::Html::SafeListSanitizer.new.sanitize(
          body, tags: %w(a img strong em b i u s table tr td ))
      end

      GenericMailer.bulkMailer(
        senders, guest, subject, body, plain: plain, attachments: attachments)
    }
  end

  def gen_email_from_template(senders, guests, template, opts = {})
    # todo: allow for user-defined arguments in template
    # map filenames to urls and convert to struct for ease of access by mustache
    links = if template.attachments.attached?
      OpenStruct.new template.attachments.map { |attachment|
        [attachment.filename.to_s.gsub(/[^0-9A-Za-z]/, '_'), url_for(attachment)]
      }.to_h
    end

    attachments = if template.attachments.attached?
      template.attachments.map { |attachment| [attachment.filename.to_s, attachment.download] }.to_h
    end

    unless opts[:attachments].nil?
      attachments = attachments.merge(opts[:attachments])
    end

    # render an email from template for each guest
    guests.map { |guest|
      subject = opts[:subject].nil? ? template.subject : opts[:subject]
      subject = Mustache.render(subject, event: guest.event, guest: guest)

      tickets = guest.guest_seat_tickets.map { |ticket|
        {
         category: ticket.seat.category,
         committed: ticket.committed,
         allotted: ticket.allotted
        }
      }

      rsvp_url = "#{request.base_url}/events/#{guest.event.id}/book?token=#{guest.id}"
      refer_url = "#{request.base_url}/events/#{guest.event.id}/refer?token=#{guest.id}"

      body = ''
      ActiveStorage::Current.set(host: request.base_url) do
        body = Mustache.render(template.body,
          sender: senders[0],
          event: guest.event,
          guest: guest,
          tickets: tickets,
          referral_rewards: guest.event.referral_rewards,
          rsvp_url: rsvp_url,
          refer_url: refer_url,
          links: links)
      end

      if template.is_html
        body = Rails::Html::SafeListSanitizer.new.sanitize(body)
        plain = Rails::Html::SafeListSanitizer.new.sanitize(
          body, tags: %w(a img strong em b i u s table tr td ))
      end

      GenericMailer.mailer(
        senders, guest, subject, body, plain: plain, attachments: attachments)
    }
  end
end
