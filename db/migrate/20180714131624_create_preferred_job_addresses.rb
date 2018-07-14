class CreatePreferredJobAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :preferred_job_addresses do |t|
      t.string :city, index: true
      t.string :country, index: true
      t.decimal :lat, index: true
      t.decimal :lng, index: true
      t.boolean "receive_notification", default: false, null: false
      t.references :user, foreign_key: true, index: true

      t.timestamps
    end
  end
end
