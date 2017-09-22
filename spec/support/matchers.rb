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