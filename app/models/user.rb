class User < ApplicationRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable


  validates :email, presence: true, unless: :social_account?

  validates :email, uniqueness: {allow_blank: true}, if: :social_account?

  validates :phone, presence: true, uniqueness: { case_sensitive: false, :allow_blank => true}, numericality: true,
            length: { :minimum => 10, :maximum => 15 }, unless: :social_account?

  devise  :database_authenticatable, :registerable, :confirmable,
          :recoverable, :rememberable, :trackable, :validatable, :timeoutable,
          :omniauthable, omniauth_providers: [:facebook, :google_oauth2],  :authentication_keys => [:phone]


  ROLES = {employer: 1, employee: 2}

  def self.create_from_provider_data(provider_data)
    where(provider: provider_data.provider, uid: provider_data.uid).first_or_create do | user |
      user.email = provider_data.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def email_required?
    false
  end

  def will_save_change_to_email?
    false
  end

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super # Use whatever other message
    end
  end

  def toggle_status!
    update_column(:approved, !approved)
  end

  private

  def social_account?
    provider.present?
  end

end
