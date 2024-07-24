require "test_helper"

class PayPeriodTest < ActiveSupport::TestCase
  context "validations" do
    should validate_presence_of :start_date
  end
end
