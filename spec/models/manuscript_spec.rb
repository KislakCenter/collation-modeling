require 'rails_helper'

include LetHelpers

RSpec.describe Manuscript, :type => :model do
  let(:ms_with_8_quires) { FactoryGirl.create(:manuscript_with_empty_quires, quires_count: 8) }
  let(:manuscript) { FactoryGirl.create :manuscript }
  let(:ms_with_leaves) { FactoryGirl.create(:manuscript_with_filled_quires, quires_count: 8)}
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

  let(:numbers_without_skips) { (1..64).map &:to_s }
  let(:numbers_with_one_skip) {
    vals = (1..65).map &:to_s
    vals.delete "10"
    vals
  }

  let(:numbers_without_skips_and_stubs) {
    vals = (1..64).map &:to_s
    vals.insert 9, [ 'stub 1', 'stub 2' ]
    vals.flatten
  }

  let(:numbers_with_skips_and_stubs) {
    vals = (1..64).map &:to_s
    vals[10] = 'stub 1'
    vals[11] = 'stub 2'
    vals.flatten
  }

  let(:numbers_starting_at_2) { (2..80).map &:to_s }
  let(:numbers_starting_at_3) { (3..80).map &:to_s }

  let(:viscoll_schema2) {
    rng = File.join(Rails.root, 'app', 'assets', 'xml', 'viscoll-datamodel2.rng')
    Nokogiri::XML::RelaxNG open rng
  }

  def fill_numbers ms, numbers
    nums_dup = numbers.dup
    ms.quire_leaves.includes(:leaf).each do |ql|
      ql.leaf.update_column :folio_number, nums_dup.shift
    end
  end

  context "factories" do
    it "create a manuscript" do
      expect(FactoryGirl.create(:manuscript)).to be_a Manuscript
    end

    it "create a manuscript with empty quires" do
      expect(FactoryGirl.create(:manuscript_with_empty_quires).quires.length).to eq 10
    end

    it "a manuscript with quires and leaves" do
      expect(FactoryGirl.create(:manuscript_with_filled_quires).quires.first.leaves.length).to eq 8
    end

  end

  context "#to_xml" do
    it "creates some xml" do
      ns = { x: 'http://schoenberginstitute.org/schema/collation' }
      expect(Nokogiri::XML(ms_with_leaves.to_xml).xpath('//x:quire', ns).length).to eq 8
    end

    it "generates an xml string" do
      expect(ms_with_leaves.to_xml).to be_a String
    end

    it "generates valid xml" do
      doc = Nokogiri::XML(ms_with_leaves.to_xml)
      expect(viscoll_schema2.validate doc).to be_blank
    end

    it "handles a single sub-quire" do
      xml = ms_with_subquire.to_xml
      expect(viscoll_schema2.validate Nokogiri::XML xml).to be_blank
    end

    it 'handles single leaves' do
      xml = manuscript_with_single_leaf.to_xml
      expect(viscoll_schema2.validate Nokogiri::XML xml).to be_blank
    end

    it 'handles single leaf in a subquire' do
      xml = manuscript_with_single_leaf_and_subquire.to_xml
      # puts xml
      expect(viscoll_schema2.validate Nokogiri::XML xml).to be_blank
    end
  end

  context "create_quires" do
    it 'creates new quires' do
      manuscript.quire_number_input = 2
      expect {
        manuscript.create_quires
      }.to change { manuscript.quires.count }.by 2
    end

    it 'creates new quires with leaves' do
      manuscript.quire_number_input = 2
      manuscript.leaves_per_quire_input = 6
      expect {
        manuscript.create_quires
        }.to change { manuscript.leaves.count }.by 12
    end
  end

  context "leaf_skips" do
    it 'finds no skips' do
      fill_numbers ms_with_leaves, numbers_without_skips
      expect(ms_with_leaves.leaf_skips).to eq([])
    end

    it 'finds no skips with intervening stub' do
      fill_numbers ms_with_leaves, numbers_without_skips_and_stubs
      expect(ms_with_leaves.leaf_skips).to eq([])
    end

    it 'finds a skip after a stub' do
      fill_numbers ms_with_leaves, numbers_with_skips_and_stubs
      skips = ms_with_leaves.leaf_skips
      expect(skips.size).to eq(1)
      expect(Leaf.find(skips.first).folio_number).to eq("13")
    end

    it 'finds a skip' do
      fill_numbers ms_with_leaves, numbers_with_one_skip
      skips = ms_with_leaves.leaf_skips
      expect(skips.size).to eq(1)
      expect(Leaf.find(skips.first).folio_number).to eq("11")
    end

    it 'finds one skip when the first folio number is 2' do
      fill_numbers ms_with_leaves, numbers_starting_at_2
      skips = ms_with_leaves.leaf_skips
      expect(skips.size).to eq(1)
      expect(Leaf.find(skips.first).folio_number).to eq("2")
    end

    it 'finds one skip when the first folio number is 3' do
      fill_numbers ms_with_leaves, numbers_starting_at_3
      skips = ms_with_leaves.leaf_skips
      expect(skips.size).to eq(1)
      expect(Leaf.find(skips.first).folio_number).to eq("3")
    end
  end

  context 'build_quire_structures' do
    it 'builds all QuireStructures' do
      structures = ms_with_leaves.build_quire_structures
      expect(structures).to be_an Array
    end
  end
end
