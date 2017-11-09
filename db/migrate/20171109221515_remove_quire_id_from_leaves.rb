class RemoveQuireIdFromLeaves < ActiveRecord::Migration
  def change
    remove_column :leaves, :quire_id, :integer
  end
end
