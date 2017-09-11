class AddSubQuireToQuireLeaves < ActiveRecord::Migration
  def up
    add_column :quire_leaves, :subquire, :integer, default: 0
    exec_update "update quire_leaves set subquire = 0", "Set subquires to default", []
  end

  def down
    remove_column :quire_leaves, :subquire
  end
end
