class CreateSearches < ActiveRecord::Migration[5.1]
  def change
    create_table :searches do |t|
      t.text    :key
      t.string  :city
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
