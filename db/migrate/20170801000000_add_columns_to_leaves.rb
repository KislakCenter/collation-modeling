class AddColumnsToLeaves < ActiveRecord::Migration
  def change
    add_column :leaves, :folio_number_certainty, :integer, default: 1
    add_column :leaves, :mode_certainty, :integer, default: 1
    add_column :leaves, :quire_certainty, :integer, default: 1
    add_column :leaves, :attachment_method, :string
    add_column :leaves, :attachment_method_certainty, :integer
  end
end