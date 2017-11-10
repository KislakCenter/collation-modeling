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
end
