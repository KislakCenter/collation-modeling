class RemoveConjoinIdFromQuireLeaves < ActiveRecord::Migration
  def change
    remove_column :quire_leaves, :conjoin_id, :integer
  end
end
