FactoryGirl.define do
  factory :leaf do
    quire
    sequence(:folio_number) { |n| n }
  end

end
