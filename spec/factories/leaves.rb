FactoryGirl.define do
  rv = %w{r v}

  factory :leaf do
    sequence(:folio_number) { |n| n }
  end
end
