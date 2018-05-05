FactoryGirl.define do
  factory :message do
    message_body "MyText"
    message_type 1
    conversation nil
    user nil
  end
end
