class AddQuireCertaintyToLeaves < ActiveRecord::Migration
  def change
    add_column :leaves, :quire_certainty, :integer, default: 1
    remove_column :leaves, :quire_uncertain, :boolean, default: false
  end
end
