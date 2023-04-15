require 'rails_helper'

RSpec.describe EventsController, type: :controller do
    describe 'showing homepage' do
        it 'should display the import form with the index template' do
			get :index
			expect(response).to render_template('index')
		end
	end
	
	#commented - test not working - SP
	# describe 'showing the event details' do
	#     let(:event) {Event.create :id => 1, :title => 'fake_title', :date => 'fake_date', :box_office_customers => ''}
	# 	it 'should display the correct basic event information with the show template' do
	# 		Event.stub(:find).and_return(event)
	# 		get :show, {:id => event.id}
	# 		expect(assigns(:event)).to eq event
	# 		expect(response).to render_template('show')
	# 	end
		
	# 	it 'should display all the correct guest details of the event with the show template' do
	# 		guest_1 = Guest.create :id => 1, :event_id => event.id, :first_name => 'fake_first_name_1', :last_name => 'fake_last_name_1', :email_address => 'fake_email_address_1'
	# 		guest_2 = Guest.create :id => 2, :event_id => event.id, :first_name => 'fake_first_name_2', :last_name => 'fake_last_name_2', :email_address => 'fake_email_address_2'
 #           guest_3 = Guest.create :id => 3, :event_id => event.id, :first_name => 'fake_first_name_3', :last_name => 'fake_last_name_3', :email_address => 'fake_email_address_3'
	# 		event.stub(:guests).and_return([guest_1, guest_2, guest_3])
	# 		get :show, {:id => event.id}
	# 		expect(assigns(:guests)).to eq [guest_1, guest_2, guest_3]
	# 		expect(response).to render_template('show')
	# 	end
	# end
	
	describe "GET #show" do
    let(:event) { create(:event) }
    let(:seat1) { create(:seat, event: event) }
    let(:seat2) { create(:seat, event: event) }
    let(:guest1) { create(:guest, event: event) }
    let(:guest2) { create(:guest, event: event) }
    let(:boxoffice_seat1) { create(:boxoffice_seat, event: event) }
    let(:boxoffice_seat2) { create(:boxoffice_seat, event: event) }

    before do
      get :show, params: { id: event.id }
    end

    it "assigns the event" do
      expect(assigns(:event)).to eq(event)
    end

    it "assigns the event ID" do
      expect(assigns(:event_id)).to eq(event.id.to_s)
    end

    it "assigns the seats" do
      expect(assigns(:seats)).to match_array([seat1, seat2])
    end

    it "assigns the guests" do
      expect(assigns(:guests)).to match_array([guest1, guest2])
    end

    it "assigns the box office seats" do
      expect(assigns(:boxoffice_seats)).to match_array([boxoffice_seat1, boxoffice_seat2])
    end

    it "renders the show template" do
      expect(response).to render_template("show")
    end
  end

  describe "GET #edit" do
    let(:event) { create(:event) }

    before do
      get :edit, params: { id: event.id }
    end

    it "assigns the event" do
      expect(assigns(:event)).to eq(event)
    end

  end


  describe "DELETE #destroy" do
    let(:event) { create(:event) }

      before do
        delete :destroy, params: { id: event.id }
      end

      it "deletes the event" do
        expect(Event.exists?(event.id)).to be_falsey
      end

      it "redirects to root_path" do
        expect(response).to redirect_to(root_path)
      end

  end
	
end


