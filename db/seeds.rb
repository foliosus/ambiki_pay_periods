# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

# Set up some pay periods on a regular cadence.
if PayPeriod.count == 0
  start_date = Date.today - 1
  10.times do |n|
    PayPeriod.create(start_date: start_date, end_date: start_date + 14.days)
    start_date += 15.days
  end
end
