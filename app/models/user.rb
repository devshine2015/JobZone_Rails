class User < ApplicationRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  validates :email, :uniqueness => {:allow_blank => true}

  validates :phone,presence: true,
            uniqueness: { case_sensitive: false },
            numericality: true,
            length: { :minimum => 10, :maximum => 15 }

  devise  :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable, :lockable, :timeoutable,
          :omniauthable, omniauth_providers: [:facebook, :google_oauth2],  :authentication_keys => [:phone]

  def self.create_from_provider_data(provider_data)
    where(provider: provider_data.provider, uid: provider_data.uid).first_or_create do | user |
      user.email = provider_data.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def email_required?
    false
  end

  # use this instead of email_changed? for rails >= 5.1
  def will_save_change_to_email?
    false
  end

end
