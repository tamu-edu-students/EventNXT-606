require 'rails_helper'

RSpec.describe "show edit and destroy options", type: :view do
  before(:each) do
    @seat = assign(:seat, Seat.create!(
        :category => 'a',
        :total_count => 20,
        :event_id => 10
    ))
  end
  it "renders a list of seats" do
    render @seat
    assert_select "div>a", :text => "Edit".to_s, :count => 1
    assert_select "div>a", :text => "Destroy".to_s, :count => 1
  end
end
