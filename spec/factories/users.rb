FactoryBot.define do
  factory :user do
    email { 'test@example.com' }
    password { 'password123' }
    date_of_birth { 20.years.ago.to_date }
  end
end
