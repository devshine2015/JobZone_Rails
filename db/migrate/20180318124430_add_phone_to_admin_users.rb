class AddPhoneToAdminUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_users, :phone, :string
  end
end
