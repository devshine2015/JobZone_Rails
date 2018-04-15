class Job < ApplicationRecord
  belongs_to :user
  belongs_to :company
  has_many :employee_jobs

  STATUS = { active: 1, closed: 2}

  self.per_page = 10

  def self.search(key, page)
    where("title ILIKE ?", "%#{key}%").page(page).order('created_at DESC')
  end

  def as_json(options = nil)
    super(
      only: [:id, :title, :location, :status_id],
      methods: [:status, :created_date],
      include: {
          company: {
              only: [:id, :title]
          }
      }
    )
  end

  def status
    STATUS.key(status_id)
  end

  def created_date
    created_at.strftime("%B %d, %y")
  end
end
