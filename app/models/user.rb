class User < ApplicationRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable


  validates :role_id, presence: true
  validates :email, presence: true, uniqueness: {allow_blank: true}, if: :social_account?

  validates :phone, presence: true, uniqueness: { case_sensitive: false, :allow_blank => true}, numericality: true,
            length: { :minimum => 10, :maximum => 15 }, unless: :social_account?

  devise  :database_authenticatable, :registerable,:token_authenticatable,
          :recoverable, :rememberable, :trackable, :validatable, :timeoutable,
          :omniauthable, omniauth_providers: [:facebook, :google_oauth2],  :authentication_keys => [:phone]

  before_save :send_verification_code, if: :new_record?

  ROLES = {employer: 1, employee: 2}

  def self.create_from_provider_data(provider_data)
    where(provider: provider_data.provider, uid: provider_data.uid).first_or_create do | user |
      user.email = provider_data.info.email
      user.password = Devise.friendly_token[0, 20]
      user.is_verified = true
    end
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
    super({ only: [:id, :phone,:email,:provider, :uid, :is_verified, :role_id, :authentication_token]}.merge(options || {}))
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

  def social_account?
    provider.present?
  end

end
