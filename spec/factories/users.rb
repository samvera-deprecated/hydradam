# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "email#{n}@example.com"
    end
    password 'password'

    factory :admin do
      admin true
    end
  end
end
