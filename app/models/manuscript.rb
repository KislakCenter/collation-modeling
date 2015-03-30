class Manuscript < ActiveRecord::Base
  has_many :quires, -> { order('position ASC') }, dependent: :destroy

  attr_accessor :quire_number_input

  before_save :build_quires

  validates_presence_of :title, :shelfmark

  def to_xml options={}
    build_xml.to_xml
  end

  def build_xml
    Nokogiri::XML::Builder.new do |xml|
      xml.manuscript {
        xml.title title
        xml.shelfmark shelfmark
        xml.quires {
          quires.each do |q|
            xml.quire(n: q.position) {
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

  private

  def build_quires
    if quires.empty? && quire_number_input
      (1..quire_number_input.to_i).each do |i|
        quires.build number: i
      end
    end
  end
end
