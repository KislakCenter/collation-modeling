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
        evaluator.leaves_count.times do
          quire.leaves << create(:leaf)
        end
      end
    end # factory :quire_with_leaves

    factory :quire_with_subquire do
      transient do
        leaves_count 8
        positions_and_subs ({ 1 => 1, 2 => 1  })
      end

      after :create do |quire,evaluator|
        evaluator.leaves_count.times do |i|
          quire.leaves << create(:leaf)
          if evaluator.positions_and_subs[i]
            quire.quire_leaves[i].update_column 'subquire', evaluator.positions_and_subs[i]
          end
        end
      end
    end
  end
end
