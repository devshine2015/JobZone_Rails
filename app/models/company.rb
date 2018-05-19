class Company < ApplicationRecord

  belongs_to :user
  has_one_attached :profile
  has_one_attached :cover

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

end
