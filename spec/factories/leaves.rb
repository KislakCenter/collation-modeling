FactoryGirl.define do
  rv = %w{r v}

  factory :leaf do
    sequence(:folio_number) { |n|
      num  = (n + 1) / 2
      side = rv[(n + 1) % 2]
      "#{num}#{side}"
    }
  end
end
