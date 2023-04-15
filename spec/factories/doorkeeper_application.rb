# spec/factories/doorkeeper_application.rb
FactoryBot.define do
    factory :doorkeeper_application, class: 'Doorkeeper::Application' do
      sequence(:name) { |n| "Application #{n}" }
      redirect_uri { 'urn:ietf:wg:oauth:2.0:oob' }
      uid { SecureRandom.hex }
      secret { SecureRandom.hex }
    end
end
  