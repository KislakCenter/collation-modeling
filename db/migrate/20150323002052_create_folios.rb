class CreateFolios < ActiveRecord::Migration
  def change
    create_table :folios do |t|
      t.string :mode
      t.boolean :single
      t.belongs_to :quire, index: true, foreign_key: true
      t.integer :position

      t.timestamps null: false
    end
  end
end
