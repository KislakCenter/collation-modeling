class RenameTableFoliosToLeaves < ActiveRecord::Migration
  def change
    rename_table :folios, :leaves
  end
end
