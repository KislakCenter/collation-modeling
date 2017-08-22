require 'rails_helper'

RSpec.describe QuireLeaf, :type => :model do
  context "factories" do
    it "builds a QuireLeaf" do
      expect(FactoryGirl.build(:quire_leaf)).to be_a QuireLeaf
    end

    it "creates a QuireLeaf" do
      expect(FactoryGirl.create(:quire_leaf)).to be_a QuireLeaf
    end
  end
end
