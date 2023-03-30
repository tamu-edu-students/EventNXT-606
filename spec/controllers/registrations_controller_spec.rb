require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  describe '#configure_permitted_parameters' do
    it 'permits the required parameters for sign up' do
      expect(controller).to receive_message_chain(:devise_parameter_sanitizer, :permit)
        .with(:sign_up)
        .with(:first_name, :last_name, :email, :password, :password_confirmation)
      controller.send(:configure_permitted_parameters)
    end
  end

  describe '#respond_with' do
    let(:resource) { double(id: 123) }

    it 'renders the resource as json' do
      expect(controller).to receive(:render).with(json: resource)
      controller.send(:respond_with, resource)
    end

    it 'returns 422 if the resource does not have an id' do
      allow(resource).to receive(:id).and_return(nil)
      expect(controller).to receive(:head).with(:unprocessable_entity)
      controller.send(:respond_with, resource)
    end

    it 'returns 200 if the resource has an id' do
      expect(controller).to receive(:head).with(:ok)
      controller.send(:respond_with, resource)
    end
  end
end
