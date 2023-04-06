require File.expand_path('../boot', __FILE__)

require 'dotenv/load'
require 'rails/all'
require 'set'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EventNXT
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += Dir[File.join(Rails.root, 'app', 'models', 'validators')]

    # skip deprecation warnings
    config.active_record.legacy_connection_handling = false
    config.active_storage.replace_on_assign_to_many = true
    config.web_console.development_only = false

    log_path = "log/#{Rails.env}.log"
    config.logger = Logger.new(log_path, 2)
    
    if ENV['USE_SENDGRID'].to_i == 1
      config.action_mailer.smtp_settings = {
        :user_name => 'apikey',
        :password => Rails.application.credentials.sendgrid[:api_key],
        :domain => ENV['DOMAIN'],
        :address => ENV['SENDGRID_DOMAIN'],
        :port => ENV['SENDGRID_PORT'],
        :authentication => :plain,
        :enable_starttls_auto => true,
      }
    else
      config.action_mailer.smtp_settings = {
        #:user_name => Rails.application.credentials.email[:user_name],
        #:password => Rails.application.credentials.email[:password],
        :address => ENV['EMAIL_DOMAIN'],
        :port => ENV['EMAIL_PORT'],
        :authentication => :plain,
        :enable_starttls_auto => true,
      }
    end
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.default_url_options = {:host => ENV['DOMAIN']}

    config.after_initialize do
      Rails.logger.info "ENVIRONMENT: #{JSON.generate(ENV.to_h)}"
      Rails.logger.info "MAIL SETTINGS: #{JSON.generate(config.action_mailer)}"
    end
  end
end
