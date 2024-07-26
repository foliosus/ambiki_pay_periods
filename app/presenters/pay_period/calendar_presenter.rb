class PayPeriod::CalendarPresenter
  attr_reader :end_date, :pay_periods, :start_date

  def initialize(start_date:, end_date:, pay_periods:)
    @start_date = start_date
    @end_date = end_date

    # Filter out any periods that are outside of the start_date..end_date time window
    date_range = (start_date..end_date)
    @pay_periods = pay_periods.select{|pp| pp.start_date.in?(date_range) || pp.end_date.in?(date_range) }

    index_pay_periods_by_date
  end

  def number_of_days
    (@end_date - @start_date).to_i + 1 # +1 because we include both of the boundary days
  end

  def pay_period_for_date(date)
    @pay_periods_indexed_by_date[date]
  end

  private def index_pay_periods_by_date
    @pay_periods_indexed_by_date = {}
    @pay_periods.each do |pp|
      (pp.start_date..pp.end_date).each do |date|
        @pay_periods_indexed_by_date[date] = pp
      end
    end
  end
end
