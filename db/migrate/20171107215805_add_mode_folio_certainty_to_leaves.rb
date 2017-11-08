class AddModeFolioCertaintyToLeaves < ActiveRecord::Migration
  def change
    add_column :leaves, :folio_certainty, :integer
    add_column :leaves, :mode_certainty, :integer
    add_column :leaves, :single_certainty, :integer
  end
end
