require 'rails_helper'
require 'pp'

include LetHelpers

module Como
  RSpec.describe QuireStructure do
    let(:structure_for_simple_quire) {
      QuireStructure.new build_quire_and_leaves
    }

    let(:structure_with_subquire) {
      q = build_quire_and_leaves
      q.quire_leaves[1].update_attribute 'subquire', 1
      q.quire_leaves[2].update_attribute 'subquire', 1
      QuireStructure.new q
    }

    let(:structure_with_nested_subquires) {
      q = build_quire_and_leaves
      q.quire_leaves[1].update_attribute 'subquire', 1
      q.quire_leaves[2].update_attribute 'subquire', 1
      q.quire_leaves[3].update_attribute 'subquire', 2
      q.quire_leaves[4].update_attribute 'subquire', 2
      q.quire_leaves[5].update_attribute 'subquire', 1
      QuireStructure.new q
    }

    let(:structure_with_bad_subquire) {
      q = build_quire_and_leaves
      q.quire_leaves[1].update_attribute 'subquire', 1
      q.quire_leaves[3].update_attribute 'subquire', 1
      QuireStructure.new q
    }

    let(:structure_with_adjacent_subquires) {
      q = build_quire_and_leaves
      q.quire_leaves[1].update_attribute 'subquire', 1
      q.quire_leaves[2].update_attribute 'subquire', 1
      q.quire_leaves[3].update_attribute 'subquire', 2
      q.quire_leaves[4].update_attribute 'subquire', 2
      QuireStructure.new q
    }

    context '#build_structure' do
      it "builds a simple quire structure" do
        expect(structure_for_simple_quire.build_structure.size).to eq 1
      end

      it "builds a structure for a quire with single subquire" do
        expect(structure_with_subquire.build_structure.size).to eq 2
      end

      it "builds a structure for a quire with nested subquires" do
        expect(structure_with_nested_subquires.build_structure.size).to eq 3
      end

      it "builds a structure for a quire with nested subquires" do
        expect(structure_with_adjacent_subquires.build_structure.size).to eq 3
      end
    end

    context '#structurally_valid?' do
      it "reports a simple quire is structurally valid" do
        expect(structure_for_simple_quire).to be_structurally_valid
      end

      it "reports a quire with subquire is a structurally valid" do
        expect(structure_with_subquire).to be_structurally_valid
      end

      it "reports a nested quire structure is structurally valid" do
        expect(structure_with_nested_subquires).to be_structurally_valid
      end

      it "reports a quire with adjacent subquires is structurally valid" do
        expect(structure_with_adjacent_subquires).to be_structurally_valid
      end

      it "reports a bad quire is not structurally valid" do
        expect(structure_with_bad_subquire).not_to be_structurally_valid
      end
    end
  end
end
