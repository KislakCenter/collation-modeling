class RemovePositionFromLeaves < ActiveRecord::Migration
  def change
    remove_column :leaves, :position, :integer
  end
end
