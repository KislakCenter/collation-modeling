class AddAttachmentMethodFieldsToLeaves < ActiveRecord::Migration
  def change
    add_column :leaves, :attachment_method, :string
    add_column :leaves, :attachment_method_certainty, :integer
  end
end
