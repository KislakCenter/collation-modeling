FactoryGirl.define do
  factory :quire_leaf do
    association :leaf
    association :quire
    certainty 1
  end
end
