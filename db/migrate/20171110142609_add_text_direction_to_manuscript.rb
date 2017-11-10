class AddTextDirectionToManuscript < ActiveRecord::Migration
  def change
    add_column :manuscripts, :text_direction, :string, default: 'l-r'
  end
end
