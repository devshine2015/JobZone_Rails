json.(
    @current_user, :id, :phone,:email,:provider, :uid, :is_verified, :role_id, :authentication_token, :local
)
json.preferred_job_address @current_user.preferred_job_address.as_json(only: [:city, :country, :lat, :lng, :receive_notification])