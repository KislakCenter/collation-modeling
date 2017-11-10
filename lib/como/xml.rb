module Como
  ##
  # Como::XML is a class for generating Collation-Modeller XML; compliant with
  # the viscoll-datamodel2 schema
  class XML
    attr_reader :manuscript

    TEI_NS        = 'http://www.tei-c.org/ns/1.0'.freeze
    COLLATION_NS  = 'http://schoenberginstitute.org/schema/collation'.freeze
    NS_HASH       = { 'xmlns:tei': TEI_NS, 'xmlns': COLLATION_NS }.freeze

    def initialize manuscript
      @manuscript = manuscript
    end

    def build_xml
      quire_structures = build_quire_structures
      Nokogiri::XML::Builder.new encoding: "UTF-8" do |xml|
        xml.viscoll(NS_HASH) do
          xml.manuscript do
            add_ms_parts xml
            add_quires xml, quire_structures
            add_leaves xml, quire_structures
          end
        end
      end
    end

    def add_ms_parts xml
      xml.url manuscript.url
      xml.title manuscript.title
      xml.shelfmark manuscript.shelfmark
      xml.direction val: manuscript.text_direction
    end

    def add_leaves xml, quire_structures
      leaves_hash = collect_leaves quire_structures
      leaves_hash.keys.each do |leaf|
        xml.leaf('xml:id': leaf.xml_id) do
          add_folio_number xml, leaf
          add_mode xml, leaf
          add_qs xml, leaves_hash, leaf
          add_single xml if leaf.single?
          add_attachment_method xml, leaf if leaf.attachment_method.present?
        end
      end
    end

    def add_attachment_method xml, leaf
      attrs = { type: leaf.attachment_method }
      certainty = leaf.attachment_method_certainty
      attrs[:certainty] = certainty if certainty.present?
      xml.send :"attachment-method", leaf.attachment_method, attrs
    end

    def add_single xml
      attrs = { val: 'yes' }
      xml.single attrs
    end

    def add_mode xml, leaf
      attrs = { val: leaf.mode }
      attrs[:certainty] = leaf.mode_certainty unless leaf.false_leaf?
      xml.mode attrs
    end

    def add_qs xml, leaves_hash, leaf
      leaves_hash[leaf].each do |slot, squire|
        add_q xml, leaf, slot, squire
      end
    end

    def add_q xml, leaf, slot, subquire
      attrs = { target: "##{subquire.xml_id}", n: subquire.quire_number,
                position: subquire.substructure_position(slot) }
      attrs[:certainty] = leaf.q_certainty if leaf.q_certainty.present?
      attrs[:leafno]    = slot.leaf_no if slot.leaf_no.present?
      xml.q(attrs) do
        add_conjoin xml, slot
      end
    end

    def add_conjoin xml, slot
      # TODO: remove hard-coded conjoin certainty; use ???
      attrs = { certainty: 1, target: "##{slot.conjoin.leaf.xml_id}" }
      xml.conjoin attrs
    end

    def add_folio_number xml, leaf
      return if leaf.folio_number.blank?
      attrs = { val: leaf.folio_number,
                certainty: leaf.folio_number_certainty }
      xml.folioNumber leaf.folio_number, attrs
    end

    ##
    # Generate <quires> stanza:
    #
    #       <quire xml:id="lewis_e_101-q-1" n="1">1</quire>
    #
    def add_quires xml, quire_structures
      xml.quires do
        quire_structures.each do |structure|
          structure.subquires.each do |squire|
            attrs = { n: squire.quire_number, "xml:id": squire.xml_id }
            squire.has_parent? && attrs[:parent] = "##{squire.parent.xml_id}"
            xml.quire squire.quire_number, attrs
          end
        end
      end
    end

    # TODO: move collect_leaves to better class
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

    # TODO: move build_quire_structures to better class
    def build_quire_structures
      manuscript.quires.includes(quire_leaves: :leaf).map do |quire|
        qs = Como::QuireStructure.new quire
        qs.build
        qs
      end
    end

    def to_xml
      build_xml.to_xml
    end
  end
end