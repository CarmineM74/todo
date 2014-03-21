require 'faker'

FactoryGirl.define do
  factory :project do
    title { Faker::Internet.domain_word + "_" + DateTime.now.to_s + "#{rand}" }
    sequence :description do |n|
      "project n. #{n} description"
    end

    user

    factory :project_with_tasks do
      after(:create) do |p,evaluator|
        create_list(:task, 5, project: p)
      end
    end

  end
end
