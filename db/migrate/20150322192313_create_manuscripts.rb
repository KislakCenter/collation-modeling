class CreateManuscripts < ActiveRecord::Migration
  def change
    create_table :manuscripts do |t|
      t.string :title
      t.string :shelfmark
      t.string :url

      t.timestamps null: false
    end
  end
end
