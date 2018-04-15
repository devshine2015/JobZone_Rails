class CreateEmployeeJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :employee_jobs do |t|
      t.integer :status_id, default: 1
      t.integer :employee_id
      t.references :job, foreign_key: true

      t.timestamps
    end
  end
end
