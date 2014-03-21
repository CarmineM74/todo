require 'faker'

FactoryGirl.define do
  factory :user do
    name { Faker::Name.name + "_" + DateTime.now.to_s + "_#{rand}"}
    password "mysecret"
    password_confirmation "mysecret"

    factory :user_with_projects do
      after(:create) do |u,evaluator|
        create_list(:project_with_tasks, 3, user: u)
      end
    end
  end
end
