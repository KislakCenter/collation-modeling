class CreateQuires < ActiveRecord::Migration
  def change
    create_table :quires do |t|
      t.string :number
      t.integer :position

      t.timestamps null: false
    end
  end
end
