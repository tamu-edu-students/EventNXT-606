class GuestReferral < ApplicationRecord
  belongs_to :guest

  validates :email, presence: true, uniqueness: { scope: :event }
end
