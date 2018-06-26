class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :title
      t.references :industry, foreign_key: true

      t.timestamps
    end
    add_index :categories, [:title, :industry_id]
  end
end
