require 'faker'

FactoryGirl.define do
  factory :task do
    name { Faker::Internet.domain_word + "_" + DateTime.now.to_s + "_#{rand}" }
    sequence :description do |n|
      "task n. #{n} description"
    end
    project
  end
end
