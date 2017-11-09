class AddModeFolioCertaintyToLeaves < ActiveRecord::Migration
  def change
    add_column :leaves, :folio_certainty, :integer, default: 1
    add_column :leaves, :mode_certainty, :integer, default: 1
    add_column :leaves, :single_certainty, :integer, default: 1
  end
end
