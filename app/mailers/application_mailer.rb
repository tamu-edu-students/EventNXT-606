class ApplicationMailer < ActionMailer::Base
  default from: "vaibhavwaste96@gmail.com"#ENV['DEFAULT_EMAIL']
  layout 'mailer'
end
