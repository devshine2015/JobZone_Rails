class AddColumnsToJobs < ActiveRecord::Migration[5.1]
  def change
    rename_column :jobs, :location, :address
    add_column :jobs, :city, :string
    add_column :jobs, :country, :string
  end
end
