require 'rqrcode'
require 'chunky_png'


class QrCodeService
  def self.generate_qr_code(guest)
    # Generate QR code for the guest
    qrcode = RQRCode::QRCode.new(guest.id.to_s)
    # Convert the QR code to an SVG string
    svg = qrcode.as_svg(offset: 0, color: '000',
                      shape_rendering: 'crispEdges',
                      module_size: 11)
  end

  def self.process_qr_code(qr_code_data)
    # Process the QR code data and return the corresponding guest
    # This part is a bit tricky, because reading QR codes usually requires
    # an external service or device, like a smartphone camera.
    # For now, let's assume you have a way to read the QR code data and
    # convert it back to a string.
    guest_id = qr_code_data.to_s
    guest = Guest.find(guest_id)
  end

  def self.generate_qr_code_png(guest)
    qrcode = RQRCode::QRCode.new(guest.id.to_s)
    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 120
    )
    # Convert PNG data to Base64 string to store in database
    Base64.encode64(png.to_s)
  end

end