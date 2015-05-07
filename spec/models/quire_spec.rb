require 'rails_helper'
require 'pp'

RSpec.describe Quire, :type => :model do

  def build_quire_and_leaves leaf_count=8, *singles
    quire = FactoryGirl.create(:quire)
    leaf_count.times do |i|
      attrs = { folio_number: i+1 }
      attrs[:single] = singles.include?(attrs[:folio_number])
      quire.leaves.create attrs
    end
    quire
  end

  let(:quire_8_regular)               { build_quire_and_leaves  }

  let(:quire_7_middle_single)         { build_quire_and_leaves 7, 4 }

  let(:quire_7_first_single)          { build_quire_and_leaves 7, 1 }

  let(:quire_7_second_single)         { build_quire_and_leaves 7, 2 }

  let(:quire_7_third_single)          { build_quire_and_leaves 7, 3 }

  let(:quire_7_sixth_single)          { build_quire_and_leaves 7, 6 }

  let(:quire_7_last_single)           { build_quire_and_leaves 7, 7 }

  let(:quire_8_third_second_single)   { build_quire_and_leaves 8, 3, 2 }

  let(:quire_8_second_sixth_single)   { build_quire_and_leaves 8, 2, 6 }

  let(:quire_8_seventh_eighth_single) { build_quire_and_leaves 8, 7, 8 }

  let(:quire_8_second_seventh_single) { build_quire_and_leaves 8, 2, 7 }

  let(:quire_8_fourth_fifth_single)   { build_quire_and_leaves 8, 4, 5 }

  let(:quire_1_single)                { build_quire_and_leaves 1, 1 }

  let(:quire_2_singles)               { build_quire_and_leaves 2, 1, 2 }

  let(:quire_4_third_fourth_singles)  { build_quire_and_leaves 4, 3, 4 }

  context "factories" do
    it "builds a reqular quire" do
      expect(quire_8_regular.leaves.size).to eq 8
    end

    it "builds a reqular quire" do
      expect(quire_7_middle_single.leaves.size).to eq 7
    end

  end

  context "to_leaves" do
    it "prints leaves from a quire" do
      expect(quire_8_regular.to_leaves.size).to eq 8
    end

    it "prints leaves from a quire with a second single" do
      expect(quire_7_second_single.to_leaves.size).to eq 7
    end

    it "prints leaves from a quire with a second single" do
      expect(quire_8_second_sixth_single.to_leaves.size).to eq 8
    end

  end

  context "filled_quire" do
    it "prints a filled quire least" do
      expect(quire_8_second_sixth_single.filled_quire.size).to eq 10
      # puts quire_8_second_sixth_single.filled_quire
    end

    it "builds a filled quire with 8 conjoin leaves" do
      leaves = quire_8_regular.filled_quire
      expect(leaves.size).to eq 8
    end

    it "builds a filled quire with middle single" do
      leaves = quire_7_middle_single.filled_quire
      # puts leaves.pretty_inspect
      expect(leaves.size).to eq 8
    end

    it "builds a filled quire with first single" do
      leaves = quire_7_first_single.filled_quire
      # puts leaves.pretty_inspect
      expect(leaves.size).to eq 8
      expect(leaves.last.n).to be_nil
    end

    it "builds a filled quire with penultimate single" do
      leaves = quire_7_sixth_single.filled_quire
      # puts leaves.pretty_inspect
      expect(leaves.size).to eq 8
      expect(leaves[1].n).to be_nil
    end

    it "builds a filled 8 quire with 7, 8 single" do
      leaves = quire_8_seventh_eighth_single.filled_quire
      # puts leaves.pretty_inspect
      expect(leaves.size).to eq 10
      expect(leaves.first.n).to be_nil
      expect(leaves.second.n).to be_nil
    end

    it "builds a filled 7 quire with 7 single" do
      leaves = quire_7_last_single.filled_quire
      # puts leaves.pretty_inspect
      expect(leaves.size).to eq 8
      expect(leaves.first.n).to be_nil
    end

    it "builds a filled 1 quire" do
      leaves = quire_1_single.filled_quire
      # puts leaves.pretty_inspect
      expect(leaves.size).to eq 2
      expect(leaves.second.n).to be_nil
    end

    it "builds a filled 2 quire with 1, 2 single" do
      leaves = quire_2_singles.filled_quire
      # puts leaves.pretty_inspect
      expect(leaves.size).to eq 4
      expect(leaves[-1].n).to be_nil
      expect(leaves[-2].n).to be_nil
    end

    it "builds a filled quire 4 with 3 & 4 single leaves" do
      leaves = quire_4_third_fourth_singles.filled_quire
      # puts leaves.pretty_inspect
      expect(leaves.size).to eq 6
      expect(leaves[0].n).to be_nil
      expect(leaves[1].n).to be_nil
    end

    it "builds a filled quire 8 with 2, 7 single" do
      leaves = quire_8_second_seventh_single.filled_quire
      # puts leaves.pretty_inspect
      expect(leaves.size).to eq 10
      expect(leaves[2].n).to be_nil
      expect(leaves[7].n).to be_nil
    end

    it "builds a filled quire 8 with 4, 5 single" do
      leaves = quire_8_fourth_fifth_single.filled_quire
      # puts leaves.pretty_inspect
      expect(leaves.size).to eq 10
      expect(leaves[6].n).to be_nil
      expect(leaves[5].n).to be_nil
    end

  end

  context "quire units" do
    it "builds a quire model" do
      expect(quire_8_regular.units.size).to eq 4
    end

    it "builds a quire model with a middle single" do
      units = quire_7_middle_single.units
      expect(units.size).to eq 4
      expect(units.last.leaves.first.single).to eq true
    end

    it "builds a quire model with a first single" do
      units = quire_7_first_single.units
      expect(units.size).to eq 4
      # puts quire_7_first_single.to_xml
      expect(units.first.leaves.first.single).to eq true
    end

    it "builds a quire model with a second single" do
      units = quire_7_second_single.units
      expect(units.size).to eq 4
      # puts quire_7_second_single.to_xml
      expect(units.second.leaves.first.single).to eq true
    end

    it "builds a quire model with a third single" do
      units = quire_7_third_single.units
      expect(units.size).to eq 4
      # puts quire_7_third_single.to_xml
      expect(units.third.leaves.first.single).to eq true
    end

    it "builds a quire model with multiple singles" do
      units = quire_8_third_second_single.units
      # puts quire_8_third_second_single.to_xml
      expect(units.size).to eq 5
      expect(units.second.leaves.first.single).to eq true
      expect(units.third.leaves.first.single).to eq true
    end
  end
end
