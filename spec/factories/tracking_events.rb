# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tracking_event do
    pid "MyString"
    user nil
    event "MyString"
  end
end
