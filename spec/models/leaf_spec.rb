require 'rails_helper'

RSpec.describe Leaf, :type => :model do
  context 'factory' do
    it "builds a leaf" do
      expect(build :leaf).to be_a Leaf
    end

    it "creates a leaf" do
      expect(create :leaf).to be_a Leaf
    end
  end

  context "quire" do
    it "is not uncertain" do
      expect(build :leaf).not_to be_quire_uncertain
    end

    it "is uncertain" do
      expect(build :leaf, quire_uncertain: true).to be_quire_uncertain
    end
  end
end
