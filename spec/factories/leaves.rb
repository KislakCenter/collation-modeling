FactoryGirl.define do
  RV = %w{r v}

  factory :leaf do
    sequence(:folio_number) { |n|
      num  = (n + 1) / 2
      side = RV[(n + 1) % 2]
      "#{num}#{side}"
    }
  end
end
