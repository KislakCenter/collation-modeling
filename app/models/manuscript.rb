require 'ostruct'

class Manuscript < ActiveRecord::Base
  has_many :quires, -> { order('position ASC') }, dependent: :destroy
  has_many :leaves, -> { order 'quires.position, position' }, through: :quires

  attr_accessor :quire_number_input
  attr_accessor :leaves_per_quire_input
  attr_accessor :skips

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

  ##
  # Return the folio_number of the `last_saved_leaf`.
  delegate :folio_number, to: :last_saved_leaf, prefix: true, allow_nil: true

  def last_saved_folio_number
    return 0 if quires.empty?
    return 0 if leaves.empty?
    last_saved_leaf_folio_number
  end

  def to_xml options={}
    case options[:xml_type]
    when :filled_quires
      filled_quires_xml.to_xml
    else
      build_xml.to_xml
    end
  end

  def to_struct
    s = OpenStruct.new title: title, shelfmark: shelfmark, url: url, quires: []
    quires.each do |q|
      s.quires << q.to_struct
    end
    s
  end

  ##
  # This returns the 'Joins XML'
  def build_xml
    struct = to_struct
    binding.pry
    Nokogiri::XML::Builder.new do |xml|
      xml.manuscript(url: struct.url) {
        xml.title struct.title
        xml.shelfmark struct.shelfmark
        xml.quires {
          struct.quires.each do |q|
            xml.quire(n: q.n) {
              q.units.each do |u|
                xml.unit {
                  u.leaves.each do |leaf|
                    xml.leaf leaf.to_h
                  end
                } # xml.unit
              end
            } # xml.quire
          end
        } # xml.quires
      } # xml.manuscript
    end
  end

  ##
  # This returns the 'leaves XML'
  def filled_quires_xml
    Nokogiri::XML::Builder.new do |xml|
      xml.manuscript {
        xml.url url
        xml.title title
        xml.shelfmark shelfmark
        quires.each do |q|
          xml.quire(n: q.position) {
            q.filled_quire.each do |leaf|
              xml.leaf leaf.marshal_dump
            end
          }
        end
      }
    end
  end

  def show_attribures
    logger.info "=== #{self.quire_number_input} === #{self.leaves_per_quire_input} ==="
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
    skips = quires.includes(:leaves).flat_map do |quire|
      quire.leaves.flat_map do |leaf|
        v = []
        begin
          # try to convert folio_number to integer; skip on error
          Integer(leaf.folio_number)

          # use "0", to catch manuscripts that don't start with folio "1"
          comp_number = last_leaf.present? ? last_leaf.folio_number : "0"
          unless comp_number.succ == leaf.folio_number
            v = leaf.id
          end
          last_leaf = leaf
        rescue ArgumentError
          # not a numeric folio_number; skip
        rescue TypeError
          # folio_number is nil; skip
        end
        v
      end
    end
    skips
  end

  def renumber_from start_leaf
    next_num = nil
    quires.includes(:leaves).each do |quire|
      quire.leaves.each do |leaf|
        if leaf == start_leaf
          leaf.folio_number = start_leaf.new_number
          next_num = leaf.folio_number_int + 1
        elsif next_num.present?
          begin
            Integer(leaf.folio_number)
            leaf.folio_number = next_num
            next_num += 1
          rescue ArgumentError, TypeError
            # non-numeric folio number; skip
          end
        end
      end
      quire.save if next_num.present?
    end
  end

  def create_quires
    if quire_number_input.present?
      (1..quire_number_input.to_i).each do |i|
        quires.create
        quires.last.create_leaves leaves_per_quire_input
      end
    end
    self.quire_number_input = nil
    self.leaves_per_quire_input = nil
  end
end
