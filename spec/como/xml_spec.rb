require 'rails_helper'

include LetHelpers

RSpec.describe 'Como::XML' do

  # TODO: Add specs to check XML content

  let(:ms_with_leaves) {
    FactoryGirl.create(:manuscript_with_filled_quires, quires_count: 8)
  }

  let(:ms_with_subquire) {
    ms = FactoryGirl.create(:manuscript_with_filled_quires, quires_count: 2)
    q = ms.quires.first
    q.quire_leaves[1].update_attribute 'subquire', 1
    q.quire_leaves[2].update_attribute 'subquire', 1
    ms
  }

  let(:manuscript_with_single_leaf) {
    ms = FactoryGirl.create :manuscript
    ms.quires << build_quire_and_leaves(7, 2)
    ms.save
    ms
  }

  let(:manuscript_with_single_leaf_and_subquire) {
    ms = FactoryGirl.create :manuscript
    ms.quires << build_quire_and_leaves(7, 2)
    ms.save
    ms.quires[0].quire_leaves[1].update_attribute 'subquire', 1
    ms.quires[0].quire_leaves[2].update_attribute 'subquire', 1
    ms.quires[0].quire_leaves[3].update_attribute 'subquire', 1
    ms
  }

  let(:xml_for_ms_with_leaves) { Como::XML.new ms_with_leaves }
  let(:xml_for_ms_with_subquire) { Como::XML.new ms_with_subquire }
  let(:xml_for_manuscript_with_single_leaf) { Como::XML.new manuscript_with_single_leaf }
  let(:xml_for_manuscript_with_single_leaf_and_subquire) { Como::XML.new manuscript_with_single_leaf_and_subquire }

  let(:viscoll_schema2) {
    rng = File.join(Rails.root, 'app', 'assets', 'xml', 'viscoll-datamodel2.rng')
    Nokogiri::XML::RelaxNG open rng
  }

  context '#initialize' do
    it 'creates a Como::XML' do
      expect(Como::XML.new Manuscript.new).to be_a Como::XML
    end
  end

  context '#build_xml' do
    it 'creates some xml' do
      ns = { x: 'http://schoenberginstitute.org/schema/collation' }
      expect(Nokogiri::XML(xml_for_ms_with_leaves.to_xml).xpath('//x:quire', ns).length).to eq 8
    end

    it 'generates an xml string' do
      expect(xml_for_ms_with_leaves.to_xml).to be_a String
    end

    it 'generates valid xml' do
      doc = Nokogiri::XML(xml_for_ms_with_leaves.to_xml)
      expect(viscoll_schema2.validate doc).to be_blank
    end

    it 'handles a single sub-quire' do
      xml = xml_for_ms_with_subquire.to_xml
      expect(viscoll_schema2.validate Nokogiri::XML xml).to be_blank
    end

    it 'handles single leaves' do
      xml = xml_for_manuscript_with_single_leaf.to_xml
      expect(viscoll_schema2.validate Nokogiri::XML xml).to be_blank
    end

    it 'handles single leaf in a subquire' do
      xml = xml_for_manuscript_with_single_leaf_and_subquire.to_xml
      # puts xml
      expect(viscoll_schema2.validate Nokogiri::XML xml).to be_blank
    end
  end

  context 'build_quire_structures' do
    it 'builds all QuireStructures' do
      xml = Como::XML.new ms_with_leaves
      expect(xml.build_quire_structures).to be_an Array
    end
  end

end