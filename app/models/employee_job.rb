class EmployeeJob < ApplicationRecord
  belongs_to :job
  belongs_to :employee, class_name: 'User', foreign_key: 'employee_id'

  validates :employee_id, uniqueness: { scope: :job_id,
                                 message: "Already applied" }

  self.per_page = 10

  STATUS = { in_process: 1, received: 2, viewed: 3, shortlisted: 4 }


  def as_json(options = nil)
    hash = super(
        only:[:status_id],
        methods: [:status, :applied_date]
    )
    hash[:job] = job.as_json
    hash
  end

  def status
    STATUS.key(status_id)
  end

  def applied_date
    created_at.strftime("%B %d, %y")
  end
end
