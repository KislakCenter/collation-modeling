require 'ostruct'

class Manuscript < ActiveRecord::Base
  has_many :quires, -> { order('quires.position ASC') }, dependent: :destroy
  has_many :quire_leaves, lambda {
    reorder('quires.position, quire_leaves.position')
  }, through: :quires
  # TODO: fix non-distinct leaves; `reorder(...).distinct` => broken SQL
  has_many :leaves, -> { reorder('quires.position, quire_leaves.position') },
           through: :quires

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

  def last_saved_folio_number
    return 0 if quires.empty?
    return 0 if leaves.empty?
    last_saved_leaf_folio_number
  end

  def to_xml _options = {}
    build_xml.to_xml
  end

  def build_xml
    quire_structures = build_quire_structures
    leaves_hash      = collect_leaves quire_structures

    # TODO: Add single element
    # TODO: Add folio_certainty
    # TODO: Add mode_certainty

    # <leaf xml:id="lewis_e_001-13-1">
    #     <folioNumber certainty="1" val="97">97</folioNumber>
    #     <mode certainty="1" val="original"/>
    #     <q target="#lewis_e_001-q-13" certainty="2" position="8" n="13">
    #         <conjoin certainty="1" target="#lewis_e_001-13-1"/>
    #     </q>
    #     <q target="#lewis_e_001-q-14" certainty="2" position="1" n="14">
    #         <conjoin certainty="1" target="#lewis_e_001-14-8"/>
    #     </q>
    # </leaf>
    #
    # <leaf xml:id="lewis_e_101-1-5">
    #     <folioNumber certainty="1" val="5">5</folioNumber>
    #     <mode certainty="1" val="original"/>
    #     <q target="#lewis_e_101-q-1" leafno="5" position="5" n="1">
    #         <conjoin certainty="1" target="#lewis_e_101-1-2"/>
    #     </q>
    # </leaf>
    Nokogiri::XML::Builder.new encoding: "UTF-8" do |xml|
      xml.viscoll('xmlns:tei': 'http://www.tei-c.org/ns/1.0',
                  xmlns: 'http://schoenberginstitute.org/schema/collation') do
        xml.manuscript do
          xml.url url
          xml.title title
          xml.shelfmark shelfmark
          xml.direction val: 'l-r'
          xml.quires do
            quire_structures.each do |structure|
              structure.subquires.each do |squire|
                # <quire xml:id="lewis_e_101-q-1" n="1">1</quire>
                attrs = {
                  n: squire.quire_number,
                  "xml:id": squire.xml_id
                }
                if squire.has_parent?
                  attrs[:parent] = "##{squire.parent.xml_id}"
                end
                xml.quire squire.quire_number, attrs
              end
            end
          end
          leaves_hash.keys.each do |leaf|
            xml.leaf("xml:id": leaf.xml_id) do
              if leaf.folio_number.present?
                attrs = {
                  val: leaf.folio_number,
                  certainty: 1
                }
                xml.folioNumber leaf.folio_number, attrs
              end
              attrs = { val: (leaf.mode || 'false') }
              attrs[:certainty] = 1
              xml.mode attrs
              leaves_hash[leaf].each do |slot, squire|
                attrs = {
                  target: "##{squire.xml_id}",
                  n: squire.quire_number,
                  position: squire.substructure_position(slot)
                }
                attrs[:leafno] = slot.leaf_no if slot.leaf_no.present?
                xml.q(attrs) do
                  attrs = {
                    certainty: 1,
                    target: "##{slot.conjoin.leaf.xml_id}"
                  }
                  xml.conjoin attrs
                end
              end
              if leaf.single?
                attrs = { val: 'yes' }
                xml.single attrs
              end
            end
          end
        end
      end
    end
  end

  # @param [QuireStructure] quire_structures
  # @return [Hash]
  def collect_leaves quire_structures
    leaf_hash = Hash.new { |h, key| h[key] = [] }
    quire_structures.each do |structure|
      structure.subquires.each do |subquire|
        subquire.substructure.each_with_object(leaf_hash) do |quire_slot, leaf_hash|
          Rails.logger.debug {
            "Adding to Leaf #{quire_slot.leaf}: #{quire_slot} and #{subquire}"
          }
          leaf_hash[quire_slot.leaf] << [quire_slot, subquire]
        end
      end
    end
    leaf_hash
  end

  def build_quire_structures
    quires.map do |quire|
      qs = Como::QuireStructure.new quire
      qs.build
      qs
    end
  end

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
