require 'ostruct'

class Manuscript < ActiveRecord::Base
  has_many :quires, -> { order('position ASC') }, dependent: :destroy
  has_many :leaves, -> { order 'quires.position, position' }, through: :quires

  attr_accessor :quire_number_input
  attr_accessor :leaves_per_quire_input

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

  def build_xml
    struct = to_struct
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
