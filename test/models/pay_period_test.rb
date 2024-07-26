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

  context "multiple updates" do
    setup do
      # Four adjacent 3-day pay periods
      @pay_periods = [
        create(:pay_period, start_date: Date.today + 0, end_date: Date.today + 2),
        create(:pay_period, start_date: Date.today + 3, end_date: Date.today + 5),
        create(:pay_period, start_date: Date.today + 6, end_date: Date.today + 8),
        create(:pay_period, start_date: Date.today + 9, end_date: Date.today + 11),
      ]
      @target_pay_period = @pay_periods[1]
    end

    should "expand a pay period and adjust the immediate neighbors" do
      assert @target_pay_period.update_and_correct_adjacent_pay_periods(start_date: @target_pay_period.start_date - 1, end_date: @target_pay_period.end_date + 1), "Should run the update"
      expected_dates = [
        [Date.today + 0, Date.today + 1],
        [Date.today + 2, Date.today + 6],
        [Date.today + 7, Date.today + 8],
        [Date.today + 9, Date.today + 11],
      ]
      @pay_periods.collect(&:reload)
      assert_pay_periods_with_dates(@pay_periods, expected_dates)
    end

    should "shrink a pay period and adjust the immediate neighbors" do
      assert @target_pay_period.update_and_correct_adjacent_pay_periods(start_date: @target_pay_period.start_date + 1, end_date: @target_pay_period.end_date - 1), "Should run the update"
      expected_dates = [
        [Date.today + 0, Date.today + 3],
        [Date.today + 4, Date.today + 4],
        [Date.today + 5, Date.today + 8],
        [Date.today + 9, Date.today + 11],
      ]
      @pay_periods.collect(&:reload)
      assert_pay_periods_with_dates(@pay_periods, expected_dates)
    end

    should "expand a pay period so much that it 'eats' a neighbor and adjusts the other neighbors" do
      # This update takes over the 3rd pay period, and shrinks the 4th pay period
      assert @target_pay_period.update_and_correct_adjacent_pay_periods(end_date: @target_pay_period.end_date + 4), "Should run the update"
      expected_dates = [
        [Date.today + 0, Date.today + 2],
        [Date.today + 3, Date.today + 9],
        [Date.today + 10, Date.today + 11],
      ]
      remaining_pay_periods = @pay_periods[0..1] + @pay_periods[-1..]
      remaining_pay_periods.collect(&:reload)
      assert_pay_periods_with_dates(remaining_pay_periods, expected_dates)
      assert_nil PayPeriod.where(id: @pay_periods[2].id).first, "Should have deleted the 3rd pay period"
    end
  end

  private def assert_pay_periods_with_dates(pay_periods, expected_dates)
    expected_dates.each_with_index do |expected_dates, index|
      expected_start_date, expected_end_date = expected_dates
      pay_period = pay_periods[index]
      assert_equal expected_start_date, pay_period.start_date, "The #{index + 1} period should have a start date of #{expected_start_date}, but has #{pay_period.start_date}"
      assert_equal expected_end_date, pay_period.end_date, "The #{index + 1} period should have an end date of #{expected_end_date}, but has #{pay_period.end_date}"
    end
  end
end
