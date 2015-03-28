class AddDefaultsToLeaves < ActiveRecord::Migration
  def up
    change_column_default :leaves, :mode, 'original'
    change_column_default :leaves, :single, false
  end

  def down
    change_column_default :leaves, :mode, nil
    change_column_default :leaves, :single, nil
  end
end
