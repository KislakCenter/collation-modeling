class RenameFolioCertaintyToFolioNumberCertaintyInLeaves < ActiveRecord::Migration
  def change
    rename_column :leaves, :folio_certainty, :folio_number_certainty
  end
end
