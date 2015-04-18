require 'ostruct'

class Manuscript < ActiveRecord::Base
  has_many :quires, -> { order('position ASC') }, dependent: :destroy

  attr_accessor :quire_number_input

  before_save :build_quires

  validates_presence_of :title, :shelfmark

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

  private

  def build_quires
    if quires.empty? && quire_number_input
      (1..quire_number_input.to_i).each do |i|
        quires.build number: i
      end
    end
  end
end
