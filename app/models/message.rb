class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user
  after_create_commit { MessageBroadcastJob.perform_now self }
  def as_json(options = nil)
    super({ only: [:id, :message_body,:message_type,:conversation_id, :user_id]}.merge(options || {}))
  end
end
