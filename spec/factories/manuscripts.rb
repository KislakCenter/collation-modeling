FactoryGirl.define do
  factory :manuscript do
    title "Manuscript Title"
    sequence :shelfmark do |n|
      "MS Codex #{n}"
    end
    url "http://www.example.com"

    factory :manuscript_with_empty_quires do
      transient do
        quires_count 10
      end

      after(:create) do |manuscript,evaluator|
        create_list(:quire, evaluator.quires_count, manuscript: manuscript)
      end
    end

    factory :manuscript_with_filled_quires do
      transient do
        quires_count 10
      end

      after(:create) do |manuscript,evaluator|
        create_list(:quire_with_leaves, evaluator.quires_count, manuscript: manuscript)
      end
    end

  end
end
