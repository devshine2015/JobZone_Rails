class Job < ApplicationRecord
  belongs_to :user
  belongs_to :company
  has_many :employee_jobs
  has_many :skills, as: :skillable
  has_many :job_views

  STATUS = { active: 1, closed: 2}

  self.per_page = 10

  def self.search(search, page)
    includes(:skills).
    where("title LIKE ? OR city LIKE ? OR skills.name LIKE ?",
          "%#{search[:key]}%", "#{search[:city]}%", "%#{search[:key]}%"
        ).references(:skills).page(page)
        .order('jobs.created_at DESC')
  end

  def self.recommended(skills, page)
    joins(:skills).
        where("skills.name IN(?)","#{skills}"
        ).page(page)
  end

  def as_json(options = nil)
    super(
      only: [:id, :title, :address, :city, :status_id],
      methods: [:status, :created_date],
      include: {
          company: {
              only: [:id, :title]
          },
          skills: {
              only: [:id, :name]
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
