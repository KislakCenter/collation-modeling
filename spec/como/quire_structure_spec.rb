require 'rails_helper'
require 'pp'

include LetHelpers

module Como
  RSpec.describe QuireStructure do
    let(:structure_for_simple_quire) {
      QuireStructure.new build_quire_and_leaves
    }

    let(:structure_with_subquire) {
      q = build_quire_and_leaves 8
      q.quire_leaves[1].update_attribute 'subquire', 1
      q.quire_leaves[2].update_attribute 'subquire', 1
      QuireStructure.new q
    }

    let(:structure_with_nested_subquires) {
      q = build_quire_and_leaves 8
      q.quire_leaves[1].update_attribute 'subquire', 1
      q.quire_leaves[2].update_attribute 'subquire', 1
      q.quire_leaves[3].update_attribute 'subquire', 2
      q.quire_leaves[4].update_attribute 'subquire', 2
      q.quire_leaves[5].update_attribute 'subquire', 1
      q.quire_leaves[6].update_attribute 'subquire', 1
      QuireStructure.new q
    }

    let(:structure_with_bad_subquire) {
      q = build_quire_and_leaves 8
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

    let(:quire_7_first_single)          { build_quire_and_leaves 7, 1 }

    let(:quire_7_second_single)         { build_quire_and_leaves 7, 2 }

    let(:quire_7_middle_single)         { build_quire_and_leaves 7, 4 }

    let(:quire_7_last_single)           { build_quire_and_leaves 7, 7 }

    let(:quire_7_sixth_single)          { build_quire_and_leaves 7, 6 }

    let(:quire_8_seventh_eighth_single) { build_quire_and_leaves 8, 7, 8 }


    context '#build' do
      it 'builds a simple quire structure' do
        expect(structure_for_simple_quire.build.size).to eq 1
      end

      it 'builds a structure for a quire with single subquire' do
        structure_with_subquire.build
        expect(structure_with_subquire.size).to eq 2
      end

      it 'builds a structure for a quire with nested subquires' do
        structure_with_nested_subquires.build
        expect(structure_with_nested_subquires.size).to eq 3
      end

      it 'builds a structure for a quire with adjacent nested subquires' do
          structure_with_adjacent_subquires.build
          expect(structure_with_adjacent_subquires.size).to eq 3
      end

      context '(conjoins)' do
        it 'calculates the conjoins for a simple quire of bifolia' do
          expect(structure_for_simple_quire.build[0]).to have_balanced_conjoins
        end

        it 'calculates the conjoins for a simple quire with initial single' do
          structure = QuireStructure.new quire_7_first_single
          expect(structure.build[0]).to have_balanced_conjoins
          expect(structure.top[0].conjoin).to eq structure.top[7]
        end

        it 'calculates the conjoins for a simple quire with final single' do
          structure = QuireStructure.new quire_7_last_single
          structure.build
          expect(structure.top).to have_balanced_conjoins
          expect(structure.top).to have_conjoin_positions 8, 1
          # expect(structure.top[7].conjoin).to eq structure.top[0]
        end

        it 'calculates the conjoins for a simple quire with middle single' do
          structure = QuireStructure.new quire_7_middle_single
          structure.build
          expect(structure.top).to have_balanced_conjoins
          expect(structure.top).to have_conjoin_positions 4, 5
        end

        it 'calculates the conjoins for a simple quire with pre-middle single' do
          structure = QuireStructure.new quire_7_second_single
          expect(structure.build[0]).to have_balanced_conjoins
          expect(structure.top).to have_conjoin_positions 2, 7
        end

        it 'calculates the conjoins for a simple quire with post-middle single' do
          structure = QuireStructure.new quire_7_sixth_single
          expect(structure.build[0]).to have_balanced_conjoins
          expect(structure.top).to have_conjoin_positions 7, 2
        end

        it 'calculates the conjoins for a simple quire with final and pre-final single' do
          structure = QuireStructure.new quire_8_seventh_eighth_single
          expect(structure.build[0]).to have_balanced_conjoins
          expect(structure.top).to have_conjoin_positions 1, 10
          expect(structure.top).to have_conjoin_positions 2, 9
        end
      end

      context '(substructures)' do
        it "builds a substructure for a quire with nested subquires" do
          structure_with_nested_subquires.build
          expect(structure_with_nested_subquires.subquire(0).substructure_size).to eq 8
          expect(structure_with_nested_subquires.subquire(1).substructure_size).to eq 6
          expect(structure_with_nested_subquires.subquire(2).substructure_size).to eq 2
        end

        it 'creates balanced substructure for a simple quire of bifolia' do
          structure_for_simple_quire.build
          expect(structure_for_simple_quire.top.substructure.size).to eq 8
          expect(structure_for_simple_quire.top).to have_balanced_substructure
        end

        it 'creates balanced substructure for a simple quire with initial single' do
          structure = QuireStructure.new quire_7_first_single
          structure.build
          expect(structure.top.substructure.size).to eq 8
          expect(structure.top).to have_balanced_substructure
        end

        it 'creates balanced substructure for a simple quire with final single' do
          structure = QuireStructure.new quire_7_last_single
          structure.build
          expect(structure.top.substructure.size).to eq 8
          expect(structure.top).to have_balanced_substructure
        end

        it 'creates balanced substructure for a simple quire with middle single' do
          structure = QuireStructure.new quire_7_middle_single
          structure.build
          expect(structure.top.substructure.size).to eq 8
          expect(structure.top).to have_balanced_substructure
        end

        it 'creates balanced substructure for a simple quire with pre-middle single' do
          structure = QuireStructure.new quire_7_second_single
          structure.build
          expect(structure.top.substructure.size).to eq 8
          expect(structure.top).to have_balanced_substructure
        end

        it 'creates balanced substructure for a simple quire with post-middle single' do
          structure = QuireStructure.new quire_7_sixth_single
          structure.build
          expect(structure.top.substructure.size).to eq 8
          expect(structure.top).to have_balanced_substructure
        end
      end
    end


    context '#structurally_valid?' do
      it 'reports a simple quire is structurally valid' do
        expect(structure_for_simple_quire).to be_structurally_valid
      end

      it 'reports a quire with subquire is a structurally valid' do
        expect(structure_with_subquire).to be_structurally_valid
      end

      it 'reports a nested quire structure is structurally valid' do
        expect(structure_with_nested_subquires).to be_structurally_valid
      end

      it 'reports a quire with adjacent subquires is structurally valid' do
        expect(structure_with_adjacent_subquires).to be_structurally_valid
      end

      it 'reports a bad quire is not structurally valid' do
        expect(structure_with_bad_subquire).not_to be_structurally_valid
      end
    end

    context '#top_level_quire' do
      it "returns the top level subquire" do
        expect(structure_with_nested_subquires.top_level_quire).to be_a Subquire
      end

      it 'has one top level subquire' do
        expect(structure_with_subquire.build.select { |sq| sq.main_quire? }.size).to eq 1
      end
    end
  end
end
