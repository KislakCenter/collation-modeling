require 'rspec/expectations'

# RSpec::Matchers.define :have_7_fingers do
#   match do |thing|
#     thing.fingers.length == 7
#   end
# end

RSpec::Matchers.define :have_balanced_conjoins do
  match do |subquire|
    slots = subquire.slots
    slots.size.times { |i| expect(slots[i].conjoin).to eq slots[-1 - i] }
  end
  failure_message do |actual|
    "expected that #{actual} would have balanced conjoins"
  end
end

RSpec::Matchers.define :have_balanced_substructure do
  match do |subquire|
    slots = subquire.substructure
    slots.size.times { |i| expect(slots[i].conjoin).to eq slots[-1 - i] }
  end
  failure_message do |actual|
    "expected that #{actual} would have balanced conjoins"
  end
end

RSpec::Matchers.define :have_conjoin_positions do |position, conjoin_position|
  match do |subquire|
    slots = subquire.slots
    slot1 = slots[position - 1]
    slot2 = slots[conjoin_position - 1]
    expect(slot1.conjoin).to eq slot2
    # make sure reciprocal works too
    expect(slot2.conjoin).to eq slot1
  end
  failure_message do |actual|
    "expected that #{actual.substructure[position - 1]} would be conjoin with #{actual.substructure[conjoin_position - 1]}"
  end
end
