class AddQuireUncertainToLeaves < ActiveRecord::Migration
  def change
    add_column :leaves, :quire_uncertain, :boolean, default: false
  end
end
