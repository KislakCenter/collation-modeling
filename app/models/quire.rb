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

  def to_struct
    OpenStruct.new n: position, units: units
  end

  # Return a list of leaves with conjoins, filling in `nil` leaf
  # placeholders for the partners of single leaves.  For example:
  #
  # leaf n=1,   mode="original", folio_number="1", conjoin=8,   position=1
  # leaf n=2,   mode="original", folio_number="2", conjoin=nil, position=2
  # leaf n=3,   mode="original", folio_number="3", conjoin=7,   position=3
  # leaf n=nil,                                    conjoin=6,   position=4
  # leaf n=4,   mode="original", folio_number="4", conjoin=5,   position=5
  # leaf n=5,   mode="original", folio_number="5", conjoin=4,   position=6
  # leaf n=6,   mode="original", folio_number="6", conjoin=nil, position=7
  # leaf n=7,   mode="original", folio_number="7", conjoin=3,   position=8
  # leaf n=nil,                                    conjoin=2,   position=9
  # leaf n=8,   mode="original", folio_number="8", conjoin=1,   position=10
  #
  # This presentation is a convenience for building quire diagrams
  # where single leaves are balanced with blank slots.
  def filled_quire
    leaves = to_leaves.reverse
    to_leaves.each do |leaf|
      if leaf.conjoin.nil?
        cj = 0
        insertion_point = nil
        leaves.each_with_index do |rleaf,index|
          if rleaf.conjoin.blank?
            # skip it
          elsif rleaf.conjoin == cj+1
            cj += 1
          else
            insertion_point = index
            break
          end
        end
        leaves.insert insertion_point, OpenStruct.new(n: nil, conjoin: leaf.n)
      end
    end
    leaves.reverse!
    leaves.each_with_index { |leaf,index| leaf.position = (index+1) }
    leaves
  end

  def to_leaves
    leaves = []
    units.each do |unit|
      first = unit.leaves.first
      if unit.leaves.size > 1
        second = unit.leaves.second
        leaves << OpenStruct.new(first.marshal_dump.merge({ conjoin: second.n }))
        leaves << OpenStruct.new(second.marshal_dump.merge({ conjoin: first.n }))
      else
        leaves << OpenStruct.new(first.marshal_dump.merge({ conjoin: nil  }))
      end
    end
    leaves.sort_by &:n
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
