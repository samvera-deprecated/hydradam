# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :file_request do
    file "MyString"
    user nil
  end
end
