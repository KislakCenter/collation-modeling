class CreateQuireLeaves < ActiveRecord::Migration
  def next_quire? prev, curr_id
    return true unless prev.present? && prev.id == curr_id
  end

  def update_leaf_assignments
    quire = nil
    Leaf.where.not(quire_id: nil).order(:quire_id, :position).each do |leaf|
      if next_quire? quire, leaf.quire_id
        quire.save! unless quire.blank?
        quire = Quire.find leaf.quire_id
      end
      leaf.update_column 'quire_id', nil
      quire.quire_leaves.build leaf: leaf
      Rails.logger.info "Updated leaf #{leaf.inspect}"
    end
    quire.save! unless quire.blank?
  end

  def revert_leaf_assignments
    Quire.all.each do |quire|
      quire.quire_leaves.each do |quire_leaf|
        leaf = quire_leaf.leaf
        leaf.update_column 'quire_id', quire.id
        quire_leaf.destroy
        Rails.logger.info "Reverted leaf #{leaf.inspect}"
      end
    end
  end

  def up
    create_table :quire_leaves do |t|
      t.references :quire,                                  index: true, foreign_key: true
      t.references :leaf,                                   index: true, foreign_key: true
      t.integer    :position
      t.integer    :subquire,          default: 0

      t.timestamps null: false
    end

    update_leaf_assignments
  end

  def down
    revert_leaf_assignments

    drop_table :quire_leaves
  end

end
