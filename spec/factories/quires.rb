FactoryGirl.define do
  factory :quire do
    sequence :number do |n|
      "#{n}"
    end
    manuscript

    factory :quire_with_leaves do
      transient do
        leaves_count 8
      end

      after(:create) do |quire,evaluator|
        create_list(:leaf, evaluator.leaves_count, quire: quire)
      end
    end
  end
end
