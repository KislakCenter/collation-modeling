require 'ostruct'

class Quire < ActiveRecord::Base
  include XmlID

  belongs_to :manuscript
  has_many :quire_leaves, -> { order('position ASC') }, inverse_of: :quire
  has_many :leaves, through: :quire_leaves, dependent: :destroy

  belongs_to :parent_quire, class_name: "Quire", foreign_key: :parent_quire_id
  has_many :child_quires, class_name: "Quire", foreign_key: :parent_quire_id

  accepts_nested_attributes_for :quire_leaves, allow_destroy: true

  validate :must_have_even_bifolia

  acts_as_list scope: :manuscript

  alias_method :next, :lower_item
  alias_method :previous, :higher_item

  def name
    sprintf "%s  Quire %s", manuscript.title, position
  end

  # Return the last folio from the preceding quire if it exists.
  def preceding_leaf
    if persisted?
      previous.blank? ? nil : previous.leaves.last
    else
      last_saved = manuscript.last_saved_quire
      last_saved.blank? ? nil : last_saved.leaves.last
    end
  end

  def preceding_folio_number= val
    # do nothing; added to complement `preceding_folio_number` accessor
  end

  def preceding_folio_number
    if persisted?
      return 0 if previous.blank?
      previous_leaves = previous.leaves
      return nil if previous_leaves.blank?
      return previous_leaves.last.folio_number
    else
      last_saved_quire = manuscript.last_saved_quire
      return 0 if last_saved_quire.blank?
      previous_leaves = last_saved_quire.leaves
      return nil if previous_leaves.blank?
      return previous_leaves.last.folio_number
    end
  end

  # Return ++true++ if ++leaves++ has at least one conjoin pair.
  def has_conjoins? leaves
    leaves.any? { |leaf| leaf.conjoin.present? }
  end

  def last_leaf
    leaves.last
  end

  def create_leaves num_leaves
    if num_leaves.present? && leaves.blank?
      curr_folio = preceding_folio_number
      temp_leaves = []
      temp_quire_leaves = []
      num_leaves.to_i.times do
        curr_folio = inc_folio curr_folio
        quire_leaves.create certainty: 1, leaf: Leaf.new(folio_number: curr_folio)
      end
    end
  end

  def calculate_conjoins
    by_position = quire_leaves.inject({}) { |h, ql| h.merge(ql.position => ql) }
    pairs = quire_leaves.reject &:leaf_single
    until pairs.empty?
      left = pairs.shift
      right = pairs.pop
      left.update_attribute 'right_conjoin', right unless left.right_conjoin == right
    end
  end

  def subquires
    subs = []
    quire_leaves.each do |quire_leaf|
      if quire_leaf.subquire.to_i > 0
        (subs[quire_leaf.subquire] ||= []) << quire_leaf
      end
    end
      subs.compact
  end

  private

  # Make sure that the number of leaves not marked 'single' is even.
  def must_have_even_bifolia
    conjoins = leaves.reject{ |leaf| leaf.single? || leaf._destroy.present? }.size
    if conjoins.odd?
      errors.add(:base,
                 "The number of non-single leaves cannot be odd; found: #{conjoins}")
    end
  end

  # Increment the folio number. If +number+ cannot be parsed as in Integer,
  # return +nil+.
  #
  # TODO: Enable incrementing of paginated numbers, 1-2, 3-4, etc.
  #
  def inc_folio number
    # Integer(number) + 1
    begin
      Integer(number) + 1
    rescue ArgumentError, TypeError
      # if number is nil, TypeError is raised
      # if number is not an integer, ArgumentError is raised
      # in either case, return nil
      nil
    end
  end
end
