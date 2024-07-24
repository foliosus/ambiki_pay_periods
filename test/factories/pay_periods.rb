FactoryBot.define do
  factory :pay_period do
    start_date { Date.today - 1 }
    end_date { start_date + 14.days }
  end
end
