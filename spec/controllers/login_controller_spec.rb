require 'rails_helper'

RSpec.describe LoginController, type: :controller do
  describe "POST #create" do
    let(:web_app) { FactoryBot.create(:application, name: 'Web') }
    let(:user) { FactoryBot.create(:user, email: 'test@example.com', is_admin: true) }
    let(:params) { { email: user.email, password: 'password' } }
    let(:request_params) { params.merge(client_id: web_app.uid, client_secret: web_app.secret) }

    before do
      allow(Doorkeeper::Application).to receive(:find_by).and_return(web_app)
    end

    it "calls super with the correct parameters" do
      expect(controller).to receive(:super).with(request_params)
      post :create, params: params
    end

    context "when the user is an admin" do
      it "adds the 'admin' scope to the request parameters" do
        user.update(is_admin: true)
        post :create, params: params
        expect(controller.request.params).to include(scope: 'admin')
      end
    end

    context "when the user is not an admin" do
      it "does not add the 'admin' scope to the request parameters" do
        user.update(is_admin: false)
        post :create, params: params
        expect(controller.request.params).not_to include(scope: 'admin')
      end
    end
  end
end
