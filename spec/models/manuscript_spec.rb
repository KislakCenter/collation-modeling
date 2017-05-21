require 'rails_helper'

RSpec.describe Manuscript, :type => :model do
  let(:ms_with_8_quires) { FactoryGirl.create(:manuscript_with_empty_quires, quires_count: 8) }
  let(:manuscript) { FactoryGirl.create :manuscript }

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

  context "xml" do
    it "creates some xml" do
      expect(Nokogiri::XML(ms_with_8_quires.to_xml).xpath('//quire').length).to eq 8
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

end
