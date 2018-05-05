class CreateConversations < ActiveRecord::Migration[5.1]
  def change
    create_table :conversations do |t|
      t.string :name
      t.integer :candidate_id
      t.integer :employer_id
      t.references :job, foreign_key: true, index: true

      t.timestamps
    end
    add_index  :conversations, [:candidate_id, :employer_id]
  end
end
