class AddParentQuireToQuires < ActiveRecord::Migration
  def change
    add_column :quires, :parent_quire_id, :integer
    add_foreign_key :quires, :quires, column: :parent_quire_id
  end
end
