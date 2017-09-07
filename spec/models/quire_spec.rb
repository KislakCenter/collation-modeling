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

  context "parent quire" do
    it "has children" do
      child = FactoryGirl.create :quire
      expect(FactoryGirl.create(:quire, child_quires: [child]).child_quires.first).to eq child
    end
  end

  context "child quire" do
    it "belongs to a parent" do
      parent = FactoryGirl.create :quire
      expect(parent.child_quires.create.parent_quire).to eq parent
    end
  end

  context 'quire deletion' do
    it "does not delete leaves shared between quires" do
      quire1 = create :quire, leaves: [create(:leaf), create(:leaf)]
      quire2 = create :quire, leaves: quire1.leaves
      expect(quire1.leaves.count).to eq 2
      expect(quire2.leaves.count).to eq 2
      expect { quire2.destroy }.not_to change { Leaf.count }
    end

    it "does delete orphaned leaves" do
      quire1 = create :quire, leaves: [create(:leaf), create(:leaf)]
      expect(quire1.leaves.count).to eq 2
      expect { quire1.destroy }.to change { Leaf.count }
    end
  end
end
