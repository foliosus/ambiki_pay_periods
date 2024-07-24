require "application_system_test_case"

class PayPeriodsTest < ApplicationSystemTestCase
  setup do
    @pay_period = create(:pay_period)
  end

  test "visiting the index" do
    visit pay_periods_url
    assert_selector "h1", text: "Pay periods"
  end

  test "should create pay period" do
    visit pay_periods_url
    click_on "New pay period"

    fill_in "End date", with: @pay_period.end_date
    fill_in "Start date", with: @pay_period.start_date
    click_on "Create Pay period"

    assert_text "Pay period was successfully created"
    click_on "Back"
  end

  test "should update Pay period" do
    visit pay_period_url(@pay_period)
    click_on "Edit this pay period", match: :first

    fill_in "End date", with: @pay_period.end_date
    fill_in "Start date", with: @pay_period.start_date
    click_on "Update Pay period"

    assert_text "Pay period was successfully updated"
    click_on "Back"
  end

  test "should destroy Pay period" do
    visit pay_period_url(@pay_period)
    click_on "Destroy this pay period", match: :first

    assert_text "Pay period was successfully destroyed"
  end
end
