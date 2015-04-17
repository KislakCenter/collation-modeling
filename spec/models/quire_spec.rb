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

  let(:quire_8_regular)             { build_quire_and_leaves  }

  let(:quire_7_middle_single)       { build_quire_and_leaves 7, 4 }

  let(:quire_7_first_single)        { build_quire_and_leaves 7, 1 }

  let(:quire_7_second_single)       { build_quire_and_leaves 7, 2 }

  let(:quire_7_third_single)        { build_quire_and_leaves 7, 3 }

  let(:quire_8_third_second_single) { build_quire_and_leaves 8, 3, 2 }

  let(:quire_8_second_sixth_single) { build_quire_and_leaves 8, 2, 6 }

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
      # expect(quire_8_second_sixth_single.to_filled_leaves.size).to eq 7
      expect(quire_8_second_sixth_single.filled_quire.size).to eq 10
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

    it "builds a quire units with a first single" do
      units = quire_7_first_single.units
      expect(units.size).to eq 4
      # puts quire_7_first_single.to_xml
      expect(units.first.leaves.first.single).to eq true
    end

    it "builds a quire units with a second single" do
      units = quire_7_second_single.units
      expect(units.size).to eq 4
      # puts quire_7_second_single.to_xml
      expect(units.second.leaves.first.single).to eq true
    end

    it "builds a quire units with a third single" do
      units = quire_7_third_single.units
      expect(units.size).to eq 4
      # puts quire_7_third_single.to_xml
      expect(units.third.leaves.first.single).to eq true
    end

    it "builds a quire units with multiple singles" do
      units = quire_8_third_second_single.units
      # puts quire_8_third_second_single.to_xml
      expect(units.size).to eq 5
      expect(units.second.leaves.first.single).to eq true
      expect(units.third.leaves.first.single).to eq true
    end
  end
end
