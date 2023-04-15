require 'rails_helper'

RSpec.describe "Events", type: :request do
  describe "POST /events" do
    let(:valid_attributes) do
      {
        title: 'Sample Event',
        address: '123 Test Street',
        datetime: '2023-05-01T10:00:00',
        image: fixture_file_upload('#{Rails.root}/spec/fixtures/files/img/sample_image.jpeg', 'image/jpeg'),
        description: 'This is a test event',
        box_office: 100.0,
        last_modified: '2023-04-14T10:00:00',
        user_id: 1
      }
    end

    context "when the request is valid" do
      before { post events_path, params: valid_attributes }

      it "creates a new event" do
        expect(response).to have_http_status(201) # or 200, depending on your implementation
      end

      it "returns the newly created event" do
        expect(JSON.parse(response.body)).to include(valid_attributes.except(:image).as_json)
      end
    end

    # Add other contexts to test invalid cases if necessary
  end
end
