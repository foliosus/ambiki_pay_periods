class PayPeriodsController < ApplicationController
  # GET /pay_periods
  def index
    @pay_periods = PayPeriod.all
  end

  # GET /pay_periods/calendar
  def calendar
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today
    start_date = start_date - start_date.wday # Always align to Sunday
    end_date = start_date.advance(weeks: 12) - 1
    @calendar_presenter = PayPeriod::CalendarPresenter.new(
      start_date: start_date,
      end_date: end_date,
      pay_periods: PayPeriod.inclusive_of_dates(start_date, end_date).all
    )
  end

  # GET /pay_periods/new
  def new
    @pay_period = PayPeriod.new
  end

  # GET /pay_periods/1/edit
  def edit
    set_pay_period
  end

  # POST /pay_periods
  def create
    @pay_period = PayPeriod.new(pay_period_params)

    if @pay_period.save
      redirect_to @pay_period, notice: "Pay period was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pay_periods/1
  def update
    set_pay_period
    if @pay_period.update(pay_period_params)
      redirect_to @pay_period, notice: "Pay period was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /pay_periods/1
  def destroy
    set_pay_period
    @pay_period.destroy!
    redirect_to pay_periods_url, notice: "Pay period was successfully destroyed.", status: :see_other
  end

  # Use callbacks to share common setup or constraints between actions.
  private def set_pay_period
    @pay_period = PayPeriod.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  private def pay_period_params
    params.require(:pay_period).permit(:start_date, :end_date)
  end
end
