class Category < ApplicationRecord
  belongs_to :industry
  validates :title, presence: true
  has_and_belongs_to_many :users, -> { distinct }

  has_one_attached :picture

  scope :with_eager_loaded_picture, -> { eager_load(picture_attachment: :blob) }
  scope :with_preloaded_picture, -> { preload(picture_attachment: :blob) }

  self.per_page = 10

  def self.search(search, page)
    includes(:industry).where(
        "categories.title iLIKE ? OR industries.title iLIKE ?", "%#{search[:key]}%", "%#{search[:key]}%"
    ).references(:industry).order('categories.created_at DESC').page(page)
  end

  def picture_url
    picture.attached? ? picture.service_url : "/assets/default.jpg"
  end

  def as_json(options = nil)
    super({ only: [:id, :title, :industry_id], methods: [:picture_url]}.merge(options || {}))
  end
end
