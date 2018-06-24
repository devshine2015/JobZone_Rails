class User < ApplicationRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  validates :role_id, presence: true
  has_many :employee_jobs, foreign_key: 'employee_id'
  has_many :jobs
  has_many :employer_conversations, class_name: 'Conversation', foreign_key: 'employer_id'
  has_many :candidate_conversations, class_name: 'Conversation', foreign_key: 'candidate_id'
  has_many :searches, dependent: :destroy
  has_many :skills, as: :skillable
  has_many :job_views, dependent: :destroy
  has_many :messages

  has_one_attached :profile
  has_one_attached :cover

  accepts_nested_attributes_for :skills, allow_destroy: true


  validates :email, presence: true, uniqueness: {allow_blank: true}, if: :social_account?

  validates :phone, presence: true, uniqueness: { case_sensitive: false, :allow_blank => true}, numericality: true,
            length: { :minimum => 10, :maximum => 15 }, unless: :social_account?

  devise  :database_authenticatable, :registerable,:token_authenticatable,
          :recoverable, :rememberable, :trackable, :validatable, :timeoutable,
          :omniauthable, omniauth_providers: [:facebook, :google_oauth2],  :authentication_keys => [:phone]

  before_save :send_verification_code, if: :new_record?

  ROLES = {employer: 1, employee: 2}

  LANGUAGES = {en: 1, es: 2, fr: 3}


  scope :with_eager_loaded_profile, -> { eager_load(profile_attachment: :blob) }
  scope :with_preloaded_profile, -> { preload(profile_attachment: :blob) }

  scope :with_eager_loaded_cover, -> { preload(cover_attachment: :blob) }
  scope :with_preloaded_cover, -> { preload(cover_attachment: :blob) }


  def profile_url
    profile.attached? ? profile.service_url : "/assets/default.jpg"
  end

  def cover_url
    cover.attached? ? cover.service_url : "/assets/default.jpg"
  end

  def self.create_from_provider_data(provider_data)
    where(provider: provider_data.provider, uid: provider_data.uid).first_or_create do | user |
      user.email = provider_data.info.email
      user.password = Devise.friendly_token[0, 20]
      user.is_verified = true
    end
  end

  def has_role? user_role_id
    role_id == user_role_id
  end

  def already_appiled?(job_id)
    employee_jobs.where(job_id: job_id).first.present?
  end

  # Resets reset password token and send reset password instructions by email.
  # Returns the token sent in the e-mail.
  def send_reset_password_instructions
    token = set_reset_password_token
    send_reset_password_instructions_notification(token) if email.present?
    send_reset_password_instructions_message(token) if phone.present?
    token
  end

  def email_required?
    false
  end

  def will_save_change_to_email?
    false
  end

  def active_for_authentication?
    if social_account?
      super
    else
      super && is_verified?
    end
  end

  def inactive_message
    if !is_verified?
      :not_verified
    else
      super # Use whatever other message
    end
  end

  def toggle_status!
    update_column(:is_verified, !is_verified)
  end

  def as_json(options = nil)
    super({ only: [:id, :phone,:email,:provider, :uid, :is_verified, :role_id, :authentication_token, :local], methods: [:profile_url, :cover_url]}.merge(options || {}))
  end

  private

  def send_verification_code
    self.verification_code =  1_000_000 + rand(10_000_000 - 1_000_000)
    begin
      @twilio_client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
      @twilio_client.api.account.messages.create(
          from: ENV['TWILIO_PHONE_NUMBER'],
          to: self.phone,
          body: "Your verification code is #{self.verification_code}."
      )
    rescue Exception => e
      self.errors.add(:base, e.message)
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end

  def send_reset_password_instructions_message(token)
    begin
      @twilio_client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
      @twilio_client.api.account.messages.create(
          from: ENV['TWILIO_PHONE_NUMBER'],
          to: self.phone,
          body: "Change my password: "+"https://boiling-anchorage-83020.herokuapp.com/resetPassword/#{token}",
      )
    rescue Exception => e
      self.errors.add(:base, e.message)
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end

  def social_account?
    provider.present?
  end

end
