FactoryBot.define do
  factory :blacklisted_token do
    token { "MyString" }
    expires_at { "2024-09-26 00:30:33" }
  end
end
