require "test_helper"

class PayPeriod::CalendarPresenterTest < ActiveSupport::TestCase
  context "with some pay periods, a PayPeriod::CalendarPresenter" do
    setup do
      @pay_period1 = create(:pay_period, start_date: Date.today, end_date: Date.today + 1)
      @pay_period2 = create(:pay_period, start_date: Date.today + 2, end_date: Date.today + 3)
      @pay_period3 = create(:pay_period, start_date: Date.today + 4, end_date: Date.today + 5)
      @pay_periods = [@pay_period1, @pay_period2, @pay_period3]

      # Note: the presenter overlaps with periods 2 and 3, but we're passing in all 3 ... just to be sure it's filtering
      # correctly.
      @start_date = @pay_period2.start_date
      @end_date = @pay_period3.start_date
      @calendar_presenter = PayPeriod::CalendarPresenter.new(
        start_date: @start_date,
        end_date: @end_date,
        pay_periods: @pay_periods
      )
    end

    should "provide its start date" do
      assert_equal @start_date, @calendar_presenter.start_date
    end

    should "provide its end_date" do
      assert_equal @end_date, @calendar_presenter.end_date
    end

    should "provide the pay_periods, filtered according to the start & end dates" do
      assert_equal [@pay_period2, @pay_period3], @calendar_presenter.pay_periods
    end

    should "provide the (inclusive of boundaries) number of days in its time window" do
      assert_equal (@end_date - @start_date) + 1, @calendar_presenter.number_of_days
    end

    should "provide the pay period for any given date" do
      assert_nil @calendar_presenter.pay_period_for_date(@pay_period1.start_date), "Shouldn't return a pay period outside the time window"
      assert_equal @pay_period2, @calendar_presenter.pay_period_for_date(@pay_period2.start_date), "Should return a pay period for a given date that's in the time window"
      assert_equal @pay_period3, @calendar_presenter.pay_period_for_date(@pay_period3.start_date), "Should return a pay period for a given date that's in the time window"
    end
  end
end
