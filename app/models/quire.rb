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
      next_folio = next_folio_number
      leaf_count_input.to_i.times do |i|
        attrs = {}
        attrs[:folio_number] = next_folio if next_folio
        leaves.build attrs
        next_folio += 1 if next_folio
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

  def next_folio_number
    if previous.present?
      previous.leaves.last.folio_number.to_i + 1
    else
      1
    end
  end
end
