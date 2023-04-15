class ChangeCountedToBeIntegerInGuestReferrals < ActiveRecord::Migration[7.0]
  def change
      change_column :guest_referrals, :counted, :integer, using: 'counted::integer'
  end
end
