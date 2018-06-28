class Industry < ApplicationRecord

  validates :title, presence: true
  has_many :categories
  has_one_attached :picture

  scope :with_eager_loaded_picture, -> { eager_load(picture_attachment: :blob) }
  scope :with_preloaded_picture, -> { preload(picture_attachment: :blob) }


  self.per_page = 10

  def self.search(search, page)
    includes(:categories).where(
        "categories.title iLIKE ? OR industries.title iLIKE ?", "%#{search[:key]}%", "%#{search[:key]}%"
    ).references(:categories).order('industries.created_at DESC').page(page)
  end

  def picture_url
    picture.attached? ? picture.service_url : "/assets/default.jpg"
  end

  def as_json(options = nil)
    super({
            only: [:id, :title],
            methods: [:picture_url],
            include: [
                :categories=>{
                    only: [:id, :title, :industry_id],
                    methods: [:picture_url]
                }
            ]
          }.merge(options || {}))
  end
end
