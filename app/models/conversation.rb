class Conversation < ApplicationRecord
  belongs_to :job
  belongs_to :employer, class_name: 'User', foreign_key: 'employer_id'
  belongs_to :candidate, class_name: 'User', foreign_key: 'candidate_id'
  has_many :messages, dependent: :destroy


  def as_json(options = nil)
    super({ only: [:id, :name,:candidate_id,:employer_id, :job_id]}.merge(options || {}))
  end
end
