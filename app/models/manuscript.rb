require 'ostruct'

##
# Manuscript collects data about each manuscript,
class Manuscript < ActiveRecord::Base
  has_many :quires, -> { order('quires.position ASC') }, dependent: :destroy
  has_many :quire_leaves, -> {
    reorder('quires.position, quire_leaves.position')
  }, through: :quires
  # TODO: fix non-distinct leaves; `reorder(...).distinct` => broken SQL
  has_many :leaves, -> { reorder('quires.position, quire_leaves.position') },
           through: :quires

  attr_accessor :quire_number_input
  attr_accessor :leaves_per_quire_input
  attr_accessor :skips

  validates :text_direction, inclusion: { in: %w(l-r r-l) }

  TEXT_DIRECTIONS = [['Left to right', 'l-r'], ['Right to left', 'r-l']].freeze
  TEXT_DIRECTION_NAMES_BY_CODE = TEXT_DIRECTIONS.inject({}) { |memo,pair|
    memo.merge(pair.last => pair.first)
  }.freeze

  after_save :create_quires

  validates_presence_of :title, :shelfmark

  ##
  # Return the last quire persisted to the database. Quire is eager loaded.
  def last_saved_quire
    quires.includes(:leaves).where.not(id: nil).last
  end

  ##
  # Return the last leaf of the last save quire; otherwise, return `nil`.
  #
  def last_saved_leaf
    q = last_saved_quire
    q.leaves.last if q.present?
  end

  def text_direction_name
    TEXT_DIRECTION_NAMES_BY_CODE[text_direction]
  end

  ##
  # Return the folio_number of the `last_saved_leaf`.

  def last_saved_folio_number
    return 0 if quires.empty?
    return 0 if leaves.empty?
    last_saved_leaf_folio_number
  end

  def to_xml _options = {}
    xml = Como::XML.new self
    xml.build_xml.to_xml
  end

  # TODO: Remove calculate_conjoins
  def calculate_conjoins
    quires.each(&:calculate_conjoins)
  end

  def show_attributes
    logger.info "=== #{quire_number_input} === #{leaves_per_quire_input} ==="
  end

  ##
  # Return an array of ids of leaves preceded by numerical skips. An empty
  # array is returned if no skips are found.
  #
  # For example, for
  #
  #   Leaf id:  3164,  folio_number: 1
  #   Leaf id:  3165,  folio_number: 2
  #   Leaf id:  3166,  folio_number: 3
  #   Leaf id:  3167,  folio_number: 4
  #   Leaf id:  3168,  folio_number: 5
  #   Leaf id:  3169,  folio_number: 7 # <= preceding number is skipped
  #   Leaf id:  3170,  folio_number: 8
  #   Leaf id:  3171,  folio_number: 9
  #
  #  the array `[3169]` is returned because the expected preceding folio
  #  number, `6`, is not used.
  #
  # Non-numerical folio numbers are ignored. For example, for
  #
  #   Leaf id:  3164,  folio_number: 1
  #   Leaf id:  3165,  folio_number: 2
  #   Leaf id:  3166,  folio_number: 3
  #   Leaf id:  3167,  folio_number: 4
  #   Leaf id:  3168,  folio_number: 4a
  #   Leaf id:  3169,  folio_number: 4b
  #   Leaf id:  3170,  folio_number: 5
  #   Leaf id:  3171,  folio_number: 6
  #
  #  the empty array `[]` is returned because numbers '4a' and '4b' are
  #  ignored.
  #
  # If the folio number 1 is not used, this also caught. For example, for
  #
  #   Leaf id:  3165,  folio_number: 3 <= preceding number is skipped
  #   Leaf id:  3166,  folio_number: 4
  #   Leaf id:  3167,  folio_number: 5
  #   Leaf id:  3168,  folio_number: 6
  #   Leaf id:  3169,  folio_number: 7
  #   Leaf id:  3170,  folio_number: 8
  #   Leaf id:  3171,  folio_number: 9
  #
  # the array `[3165]` is returned because "1" is skipped (as is "2", but the
  # method does not determine intervening missing numbers).
  #
  def leaf_skips
    return skips if skips.present?

    last_leaf = nil
    quire_leaves.includes(:leaf).flat_map do |quire_leaf|
      next [] unless integer? quire_leaf.folio_number
      comp_number = last_leaf.present? ? last_leaf.folio_number.succ : "1"
      last_leaf = quire_leaf
      next [] if comp_number == quire_leaf.folio_number
      quire_leaf.leaf_id
    end
  end

  def integer? folio_number
    begin
      Integer folio_number
    rescue TypeError, ArgumentError
      # folio number is nil or non integer
      return false
    end
    true
  end

  def renumber_from start_leaf
    next_num = nil
    last_leaf = nil
    quire_leaves.includes(:leaf).each do |quire_leaf|
      next unless integer? quire_leaf.folio_number
      next if last_leaf == quire_leaf.leaf # don't process a leaf more than once
      last_leaf = quire_leaf.leaf
      if quire_leaf.leaf == start_leaf
        quire_leaf.leaf.update folio_number: start_leaf.new_number
        next_num = quire_leaf.folio_number.succ
        next
      end
      next unless next_num.present?
      quire_leaf.leaf.update folio_number: next_num
      next_num.succ!
    end
  end

  def create_quires
    if quire_number_input.present?
      (1..quire_number_input.to_i).each do |_i|
        quires.create
        quires.last.create_leaves leaves_per_quire_input
      end
    end
    self.quire_number_input = nil
    self.leaves_per_quire_input = nil
  end
end
