class CategoriesUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :categories_users, id: false do |t|
      t.belongs_to :category, index: true
      t.belongs_to :user, index: true
    end
  end
end
