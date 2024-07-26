require "test_helper"

class PayPeriodsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pay_period = create(:pay_period)
  end

  should "get index" do
    get pay_periods_url
    assert_response :success
  end

  should "get calendar" do
    get calendar_pay_periods_url
    assert_response :success
    this_sunday = Date.today - Date.today.wday
    assert_calendar_starts_on this_sunday
    7.times do |wday|
      assert_select ".calendar-header.wday-#{wday}", {count: 1}, "Calendar should have a day header for day #{wday}"
      assert_select ".calendar-day.wday-#{wday}", {count: 12}, "Calendar should show 12 weeks each with one day #{wday}"
    end
  end

  should "get calendar for an arbitrary start_date" do
    get calendar_pay_periods_url(start_date: Date.today + 7)
    assert_response :success
    assert_calendar_starts_on (Date.today - Date.today.wday) + 7
  end

  should "get new" do
    get new_pay_period_url
    assert_response :success
  end

  should "create pay_period" do
    assert_difference("PayPeriod.count") do
      post pay_periods_url, params: { pay_period: { start_date: @pay_period.end_date + 1, end_date: @pay_period.end_date + 2 } }
    end

    assert_redirected_to pay_period_url(PayPeriod.last)
  end

  should "get edit" do
    get edit_pay_period_url(@pay_period)
    assert_response :success
  end

  should "update pay_period" do
    patch pay_period_url(@pay_period), params: { pay_period: { end_date: @pay_period.end_date, start_date: @pay_period.start_date } }
    assert_redirected_to pay_periods_url
  end

  should "update pay_period in a turbo frame" do
    old_start_date = @pay_period.start_date
    new_start_date = old_start_date + 4
    patch pay_period_url(@pay_period, format: :turbo_stream), params: {
      start_date: Date.today + 4,
      pay_period: { start_date: new_start_date }
    }
    @pay_period.reload
    assert_equal new_start_date, @pay_period.start_date, "Should have updated the PayPeriod"
    assert response.body.include?("Pay period updated"), "Should respond with a user-facing message"
    assert_calendar_starts_on Date.today + 4
  end

  should "destroy pay_period" do
    assert_difference("PayPeriod.count", -1) do
      delete pay_period_url(@pay_period)
    end

    assert_redirected_to pay_periods_url
  end

  should "destroy pay_period in a turbo frame" do
    assert_difference("PayPeriod.count", -1) do
      delete pay_period_url(@pay_period)
    end

    assert_redirected_to pay_periods_url
  end

  private def assert_calendar_starts_on(expected_start_date)
    true_start_date = expected_start_date - expected_start_date.wday # Adjust to Sunday
    assert_select ".calendar-day:first-of-type .date[title=\"#{true_start_date.to_fs(:long)}\"]", {}, "Should render the calendar starting on #{true_start_date}"
  end
end
