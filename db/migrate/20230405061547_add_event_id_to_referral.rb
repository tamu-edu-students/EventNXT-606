class AddEventIdToReferral < ActiveRecord::Migration[7.0]
  def change
    add_column :guest_referrals, :event, :integer, null: false
  end
end
