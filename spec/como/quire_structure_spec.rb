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

    let(:structure_with_discontinuous_subquire) {
      q = build_quire_and_leaves 8
      q.quire_leaves[1].update_attribute 'subquire', 1
      q.quire_leaves[3].update_attribute 'subquire', 1
      QuireStructure.new q
    }

    let(:structure_with_deep_discontinuous_subquire) {
      # This structure is discontinuous at the grandparent level:
      #
      #       1 0
      #       2 1
      #       3 2
      #       4 0 <= intervening grandparent leaf
      #       5 2
      #       6 1
      #       7 0
      #       8 0
      #       9 0
      #
      q = build_quire_and_leaves 8
      q.quire_leaves[1].update_attribute 'subquire', 1
      q.quire_leaves[2].update_attribute 'subquire', 2
      q.quire_leaves[4].update_attribute 'subquire', 2
      q.quire_leaves[5].update_attribute 'subquire', 1
      QuireStructure.new q
    }

    let(:structure_with_discontinuous_subquire) {
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
          expect(structure_for_simple_quire).to have_subquire_with_balanced_conjoins :top
        end

        it 'calculates the conjoins for a simple quire with initial single' do
          structure = QuireStructure.new quire_7_first_single
          expect(structure).to have_subquire_with_balanced_conjoins :top
          expect(structure).to have_subquire_with_conjoin_positions :top, [1, 8]
        end

        it 'calculates the conjoins for a simple quire with final single' do
          structure = QuireStructure.new quire_7_last_single
          expect(structure).to have_subquire_with_balanced_conjoins :top
          expect(structure).to have_subquire_with_conjoin_positions :top, [8, 1]
        end

        it 'calculates the conjoins for a simple quire with middle single' do
          structure = QuireStructure.new quire_7_middle_single
          structure.build
          expect(structure).to have_subquire_with_balanced_conjoins :top
          expect(structure).to have_subquire_with_conjoin_positions :top, [4, 5]
        end

        it 'calculates the conjoins for a simple quire with pre-middle single' do
          structure = QuireStructure.new quire_7_second_single
          expect(structure).to have_subquire_with_balanced_conjoins :top
          expect(structure).to have_subquire_with_conjoin_positions :top, [2, 7]
        end

        it 'calculates the conjoins for a simple quire with post-middle single' do
          structure = QuireStructure.new quire_7_sixth_single
          expect(structure).to have_subquire_with_balanced_conjoins :top
          expect(structure).to have_subquire_with_conjoin_positions :top, [7, 2]
        end

        it 'calculates the conjoins for a simple quire with final and pre-final single' do
          structure = QuireStructure.new quire_8_seventh_eighth_single
          expect(structure).to have_subquire_with_balanced_conjoins :top
          expect(structure).to have_subquire_with_conjoin_positions :top, [[1, 10], [2, 9]]
        end
      end

      context '(substructures)' do
        it 'builds a substructure for a quire with nested subquires' do
          expect(structure_with_nested_subquires).to have_subquire_with_substructure_size :top, 8
          expect(structure_with_nested_subquires).to have_subquire_with_substructure_size 1, 6
          expect(structure_with_nested_subquires).to have_subquire_with_substructure_size 2, 2
        end

        it 'creates balanced substructure for a simple quire of bifolia' do
          expect(structure_with_nested_subquires).to have_subquire_with_substructure_size :top, 8
          expect(structure_for_simple_quire).to have_subquire_with_balanced_substructure :top
        end

        it 'creates balanced substructure for a simple quire with initial single' do
          structure = QuireStructure.new quire_7_first_single
          expect(structure).to have_subquire_with_substructure_size :top, 8
          expect(structure).to have_subquire_with_balanced_substructure :top
        end

        it 'creates balanced substructure for a simple quire with final single' do
          structure = QuireStructure.new quire_7_last_single
          expect(structure).to have_subquire_with_substructure_size :top, 8
          expect(structure).to have_subquire_with_balanced_substructure :top
        end

        it 'creates balanced substructure for a simple quire with middle single' do
          structure = QuireStructure.new quire_7_middle_single
          expect(structure).to have_subquire_with_substructure_size :top, 8
          expect(structure).to have_subquire_with_balanced_substructure :top
        end

        it 'creates balanced substructure for a simple quire with pre-middle single' do
          structure = QuireStructure.new quire_7_second_single
          expect(structure).to have_subquire_with_substructure_size :top, 8
          expect(structure).to have_subquire_with_balanced_substructure :top
        end

        it 'creates balanced substructure for a simple quire with post-middle single' do
          structure = QuireStructure.new quire_7_sixth_single
          expect(structure).to have_subquire_with_substructure_size :top, 8
          expect(structure).to have_subquire_with_balanced_substructure :top
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

      it 'reports a discontinuous quire is not structurally valid' do
        expect(structure_with_discontinuous_subquire).not_to be_structurally_valid
      end

      it 'reports a deep discontinuous quire is not structurally valid' do
        expect(structure_with_deep_discontinuous_subquire).not_to be_structurally_valid
      end
    end

    context '#discontinuous?' do
      it 'returns true for a discontinuous subquire' do
        structure = structure_with_discontinuous_subquire
        structure.build
        expect(structure.subquire 1).to be_discontinuous
      end

      it 'returns true for a deep discontinuous subquire' do
        structure = structure_with_deep_discontinuous_subquire
        structure.build
        expect(structure.subquire 2).to be_discontinuous
      end
    end

    context '#top_level_quire' do
      it 'returns the top level subquire' do
        expect(structure_with_nested_subquires.top_level_quire).to be_a Subquire
      end

      it 'has one top level subquire' do
        expect(structure_with_subquire.build.select(&:main_quire?).size).to eq 1
      end
    end
  end
end
