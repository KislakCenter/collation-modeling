class Manuscript < ActiveRecord::Base
  has_many :quires, -> { order('position ASC') }

  attr_accessor :quire_number_input

  before_create :build_quires

  def to_xml
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

  def to_hash
    manuscript = { quires: [] }
    quires.each do |q|
      manuscript[:quires] << q.to_hash
    end
    { manuscript: manuscript }
  end

  private

  def build_quires
    quire_number_input and (1..quire_number_input.to_i).each do |i|
      quires.build number: i
    end
  end
end
