class PreferredJobAddress < ApplicationRecord
  belongs_to :user
  validates :id, uniqueness: {scope: :user_id}
  validates :city, presence: true
  # validates :lat , numericality: { greater_than_or_equal_to:  -90, less_than_or_equal_to:  90 }
  # validates :lng, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :lng, :lng, numericality: true
end
