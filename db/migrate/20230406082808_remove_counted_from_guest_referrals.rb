class RemoveCountedFromGuestReferrals < ActiveRecord::Migration[7.0]
  def change
    remove_column :guest_referrals, :counted
    add_column :guest_referrals, :counted, :integer, default: 0, null: false
  end
end
