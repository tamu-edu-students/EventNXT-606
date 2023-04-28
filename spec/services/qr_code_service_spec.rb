require 'rails_helper'

RSpec.describe QrCodeService, type: :service do
  describe '.generate_qr_code' do
    let(:user) { User.create!(first_name: 'Casey', last_name: 'Quinn', email: 'user@example.com', password: 'password') }
    datetime = DateTime.new(2024, 9, 1, 8, 0, 0)
    let(:event) { Event.create!(title: 'Test Event', address: '107 Knox Dr', description: 'Test Description', datetime: datetime, user: user) }

    it 'generates a QR code for a guest' do
      guest = Guest.create!(
        first_name: 'John',
        last_name: 'Doe',
        email: 'john.doe@example.com',
        event: event,
        added_by: user.id,
        booked: false,
        checked: false
      )
      Rails.logger.info "Guest: #{guest.inspect}"

      qr_code_svg = QrCodeService.generate_qr_code(guest)

      Rails.logger.info "QR Code SVG: #{qr_code_svg.inspect}"

      # Test that the QR code contains the guest's ID
      expect(qr_code_svg).to include(guest.id.to_s)

      Rails.logger.info "QR CODE WAS GENERATED SUCCESSFULLY"
    end
  end
end
