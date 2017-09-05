class QuireLeaf < ActiveRecord::Base
  after_destroy :delete_orphan_leaves

  belongs_to :leaf
  belongs_to :quire
  belongs_to :right_conjoin, class_name: "QuireLeaf", foreign_key: :conjoin_id
  has_one :left_conjoin, class_name: "QuireLeaf", foreign_key: :conjoin_id

  validates :leaf, presence: true
  validates :quire, presence: true

  acts_as_list scope: :quire

  accepts_nested_attributes_for :leaf

  MODES = %w( original added replaced missing )

  delegate :single, to: :leaf, prefix: true, allow_nil: true
  delegate :folio_number, to: :leaf, prefix: false, allow_nil: true
  delegate :quire_uncertain, to: :leaf, prefix: false, allow_nil: true
  delegate :number, to: :quire, prefix: true, allow_nil: true
  delegate :xml_id, to: :quire, prefix: true, allow_nil: true

  def has_conjoin?
    conjoin.present?
  end

  def conjoin
    left_conjoin || right_conjoin
  end

  private

  ##
  # Clearning up: if the associated leaf belongs to no other quire, destroy it
  # now.
  def delete_orphan_leaves
    leaf.destroy if leaf.quires.count == 0
    true
  end
end
