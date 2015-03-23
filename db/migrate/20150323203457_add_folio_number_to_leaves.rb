class AddFolioNumberToLeaves < ActiveRecord::Migration
  def change
    add_column :leaves, :folio_number, :string
  end
end
