class AddQrCodeToGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :guests, :qr_code, :text
  end
end
