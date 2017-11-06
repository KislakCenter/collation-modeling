class RemoveNumberFromQuires < ActiveRecord::Migration
  def change
    remove_column :quires, :number, :string
  end
end
