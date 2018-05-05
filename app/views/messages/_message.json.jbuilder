json.extract! message, :id, :message_body, :message_type, :conversation_id, :user_id, :created_at, :updated_at
json.url message_url(message, format: :json)
