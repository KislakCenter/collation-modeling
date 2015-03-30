require 'ostruct'

class Quire < ActiveRecord::Base
  attr_accessor :leaf_count_input

  belongs_to :manuscript
  has_many :leaves, -> { order('position ASC') }, dependent: :destroy
  accepts_nested_attributes_for :leaves

  before_save :create_leaves

  validate :must_have_even_bifolia

  acts_as_list scope: :manuscript

  def next
    lower_item
  end

  def previous
    higher_item
  end

  # Create a list of units. Each unit corresponds to a single leaf or
  # conjoin and thus contains either one or two leaves.
  def units
    units = []
    leaf_queue = leaves.map(&:itself)
    while leaf_queue.size > 0 do
      leaf = leaf_queue.shift.to_struct
      if leaf.single
        units << OpenStruct.new(leaves: [ leaf ])
      else
        while leaf_queue.last && leaf_queue.last.single
          units << OpenStruct.new(leaves: [ leaf_queue.pop.to_struct ])
        end
        units << OpenStruct.new(leaves: [ leaf, leaf_queue.pop.to_struct ])
      end
    end
    units.sort_by! { |u| u.leaves.first.n }
    units
  end

  private

  def create_leaves
    if leaf_count_input && leaves.blank?
      curr_folio = prev_folio_number
      leaf_count_input.to_i.times do
        curr_folio = inc_folio curr_folio
        leaves.build folio_number: curr_folio
      end
    end
  end

  # Make sure that the number of leaves not marked 'single' is even.
  def must_have_even_bifolia
    conjoins = leaves.reject{ |leaf| leaf.single? }.size
    if conjoins.odd?
      errors.add(:base, "The number of non-single leaves cannot be odd; found: #{conjoins}")
    end
  end

  # Increment the folio number. If +number+ cannot be parsed as in Integer,
  # return +nil+.
  #
  # TODO: Enable incrementing of paginated numbers, 1-2, 3-4, etc.
  #
  def inc_folio number
    begin
      Integer(number) + 1
    rescue ArgumentError, TypeError
      # if number is nil, TypeError is raised
      # if number is not an integer, ArgumentError is raised
      # in either case, return nil
      nil
    end
  end

  def prev_folio_number
    if previous.present?
      previous.leaves.last.folio_number.to_i
    else
      0
    end
  end
end
