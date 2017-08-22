class CreateQuireLeaves < ActiveRecord::Migration
  def change
    create_table :quire_leaves do |t|
      t.references :leaf, index: true, foreign_key: true
      t.references :quire, index: true, foreign_key: true
      t.integer :certainty

      t.timestamps null: false
    end
  end
end
