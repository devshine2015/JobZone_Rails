class Conversation < ApplicationRecord
  belongs_to :job
  belongs_to :employer, class_name: 'User', foreign_key: 'employer_id'
  belongs_to :candidate, class_name: 'User', foreign_key: 'candidate_id'
  has_many :messages, dependent: :destroy
end
