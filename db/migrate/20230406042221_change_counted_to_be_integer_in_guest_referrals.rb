class ChangeCountedToBeIntegerInGuestReferrals < ActiveRecord::Migration[7.0]
  def change
      #change_column :guest_referrals, :counted, 'integer USING CAST(counted AS integer)'
      ALTER TABLE :guest_referrals ALTER COLUMN :counted TYPE integer USING (counted::integer);
  end
end
