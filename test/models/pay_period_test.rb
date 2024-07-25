require "test_helper"

class PayPeriodTest < ActiveSupport::TestCase
  context "validations" do
    should validate_presence_of(:start_date)
    should validate_presence_of(:end_date)

    should "validate that the end_date is on or after the start_date" do
      pay_period = build(:pay_period)
      assert pay_period.valid?, "Sanity check"

      pay_period.end_date = pay_period.start_date
      assert pay_period.valid?, "Should be valid with a start_date and end_date that are the same"

      pay_period.end_date = pay_period.start_date - 1
      refute pay_period.valid?, "Should not be valid with an end_date before the start_date"
    end

    should "validate that the date range is non-overlapping" do
      saved_pay_period = create(:pay_period)

      non_overlapping_pay_period = build(:pay_period, start_date: saved_pay_period.end_date + 1, end_date: saved_pay_period.end_date + 2)
      assert non_overlapping_pay_period.valid?, "A pay period should be valid if it doesn't overlap other pay periods"

      overlapping_pay_period = build(:pay_period, start_date: saved_pay_period.end_date, end_date: saved_pay_period.end_date + 1)
      refute overlapping_pay_period.valid?, "A pay period should not be valid if it overlaps other periods"
    end
  end

  context "time conversions" do
    setup do
      @pay_period = build(:pay_period)
    end

    should "provide a start_time at the beginning of its start_date" do
      expected_time = @pay_period.start_date.beginning_of_day
      assert_equal expected_time, @pay_period.start_time
    end

    should "provide an end_time at the end of its end_date" do
      expected_time = @pay_period.end_date.end_of_day
      assert_equal expected_time, @pay_period.end_time
    end
  end
end
