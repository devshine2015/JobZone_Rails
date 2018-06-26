class Industry < ApplicationRecord
  validates :title, presence: true

  has_one_attached :picture

  scope :with_eager_loaded_picture, -> { eager_load(picture_attachment: :blob) }
  scope :with_preloaded_picture, -> { preload(picture_attachment: :blob) }


  def picture_url
    picture.attached? ? picture.service_url : "/assets/default.jpg"
  end

  def as_json(options = nil)
    super({ only: [:id, :title], methods: [:picture_url]}.merge(options || {}))
  end
end
