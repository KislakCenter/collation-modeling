class QuireLeaf < ActiveRecord::Base
  after_destroy :delete_orphan_leaves

  belongs_to :leaf
  belongs_to :quire

  validates :leaf, presence: true
  validates :quire, presence: true

  SUBQUIRES = ([['Main', 0]] + (1..10).map { |i| [i, i] }).freeze

  acts_as_list scope: :quire

  accepts_nested_attributes_for :leaf

  delegate :single?,                to: :leaf,  prefix: true,  allow_nil: true
  delegate :folio_number,           to: :leaf,  prefix: false, allow_nil: true
  delegate :folio_number_certainty, to: :leaf,  prefix: false, allow_nil: true
  delegate :quire_uncertain,        to: :leaf,  prefix: false, allow_nil: true
  delegate :mode,                   to: :leaf,  prefix: true,  allow_nil: true
  delegate :mode_certainty,         to: :leaf,  prefix: true,  allow_nil: true
  delegate :number,                 to: :quire, prefix: true,  allow_nil: true
  delegate :xml_id,                 to: :quire, prefix: true,  allow_nil: true

  def to_s
    "#{self.class.name}: quire: #{quire}; leaf: #{leaf}"
  end

  private

  ##
  # Cleaning up: if the associated leaf belongs to no other quire, destroy it
  # now.
  def delete_orphan_leaves
    leaf.destroy if leaf.quires.count == 0
    true
  end
end
