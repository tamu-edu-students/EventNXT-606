require 'rails_helper'

RSpec.describe EventsController, type: :controller do
    describe 'showing homepage' do
        it 'should display the import form with the index template' do
			get :index
			expect(response).to render_template('index')
		end
	end
	
	describe 'showing the event details' do
	    let(:event) {Event.create :id => 1, :title => 'fake_title', :date => 'fake_date', :box_office_customers => ''}
		it 'should display the correct basic event information with the show template' do
			Event.stub(:find).and_return(event)
			get :show, {:id => event.id}
			expect(assigns(:event)).to eq event
			expect(response).to render_template('show')
		end
		
		it 'should display all the correct guest details of the event with the show template' do
			guest_1 = Guest.create :id => 1, :event_id => event.id, :first_name => 'fake_first_name_1', :last_name => 'fake_last_name_1', :email_address => 'fake_email_address_1'
			guest_2 = Guest.create :id => 2, :event_id => event.id, :first_name => 'fake_first_name_2', :last_name => 'fake_last_name_2', :email_address => 'fake_email_address_2'
            guest_3 = Guest.create :id => 3, :event_id => event.id, :first_name => 'fake_first_name_3', :last_name => 'fake_last_name_3', :email_address => 'fake_email_address_3'
			event.stub(:guests).and_return([guest_1, guest_2, guest_3])
			get :show, {:id => event.id}
			expect(assigns(:guests)).to eq [guest_1, guest_2, guest_3]
			expect(response).to render_template('show')
		end
	end

    # test for deleting an event and redirecting to the events index page
	describe 'DELETE #destroy' do
    it 'deletes the event and redirects to the events index page' do
      event = create(:event)
      expect {
        delete :destroy, params: { id: event.id }
      }.to change(Event, :count).by(-1)

      expect(response).to redirect_to(root_path)
    end
  end
	
end


