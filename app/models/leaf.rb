class Leaf < ActiveRecord::Base
  include XmlID

  # TODO: Change quire_uncertain to quire_certainty

  # Number for renumbering this quire
  attr_accessor :new_number

  FOLIO_NUMBERS       = (1..1000).to_a.freeze
  MODES               = %w( original added replaced missing ).freeze
  ATTACHMENT_METHODS  = %w( sewn glued tipped drummed ).freeze

  has_many :quire_leaves, inverse_of: :leaf
  has_many :quires, through: :quire_leaves

  scope :without_children, -> {
    includes(:quire_leaves).where(:quire_leaves => { :id => nil })
  }

  validates :attachment_method,
            inclusion: { in: ATTACHMENT_METHODS }, allow_nil: true

  def manuscript
    quires.present? and quires.first.manuscript or nil
  end

  def next
    lower_item
  end

  def previous
    higher_item
  end

  def false_leaf?
    mode.present? && mode.casecmp?('false')
  end

  def folio_number_int
    folio_number.to_i
  end

  def following_leaf
    return lower_item if lower_item.present?
    quire_next.leaves.first if quire_next.present?
  end
  delegate :folio_number, to: :following_leaf, prefix: true, allow_nil: true

  def next_skipped?
    begin
      Integer(folio_number) + 1 != Integer(following_leaf_folio_number)
    rescue ArgumentError, TypeError
      false
    end
  end

  def description
    s = "Leaf #{position.to_s}"
    s += " (fol/pg #{folio_number})" if folio_number.present?
    s += " #{mode}; "
    s += single? ? 'single' : 'conjoins'
    s
  end

  def to_s
    folio_number
  end
end
