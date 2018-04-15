json.extract! job, :id, :title, :location, :status_id, :description, :user_id, :company_id, :created_at, :updated_at
json.url job_url(job, format: :json)
