class RemoveSingleCertaintyFromLeaves < ActiveRecord::Migration
  def change
    remove_column :leaves, :single_certainty, :integer
  end
end
