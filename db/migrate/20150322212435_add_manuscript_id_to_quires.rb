class AddManuscriptIdToQuires < ActiveRecord::Migration
  def change
    add_reference :quires, :manuscript, index: true, foreign_key: true
  end
end
