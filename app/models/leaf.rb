class Leaf < ActiveRecord::Base
  include XmlID

  # Number for renumbering this quire
  attr_accessor :new_number
  FOLIO_NUMBERS = (1..600).to_a

  has_many :quire_leaves, inverse_of: :leaf
  has_many :quires, through: :quire_leaves

  scope :without_children, -> {
    includes(:quire_leaves).where(:quire_leaves => { :id => nil })
  }

  acts_as_list scope: :quire

  def manuscript
    quires.present? and quires.first.manuscript or nil
  end

  def next
    lower_item
  end

  def previous
    higher_item
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
    s = "Leaf "
    s += position.to_s
    if folio_number.present?
      s += " (fol/pg "
      s += folio_number
      s += ")"
    end
    s += " "
    s += mode
    s += "; "
    s += single? ? "single" : "conjoin"
  end
end
