class PayPeriodsController < ApplicationController
  # GET /pay_periods
  def index
    @pay_periods = PayPeriod.all
  end

  # GET /pay_periods/calendar
  def calendar
    load_calendar_presenter
  end

  # GET /pay_periods/new
  def new
    set_calendar_start_date
    start_date = params.dig(:pay_period, :start_date) || Date.today
    @pay_period = PayPeriod.new(start_date: start_date, end_date: start_date)
  end

  # GET /pay_periods/1/edit
  def edit
    set_pay_period
    set_calendar_start_date
  end

  # POST /pay_periods
  def create
    @pay_period = PayPeriod.new(pay_period_params)

    if @pay_period.save
      respond_to do |format|
        format.html do
          redirect_to @pay_period, notice: "Pay period was successfully created."
        end
        format.turbo_stream do
          load_calendar_presenter
          render :create
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pay_periods/1
  def update
    set_pay_period
    if @pay_period.update(pay_period_params)
      respond_to do |format|
        format.html do
          redirect_to pay_periods_path, notice: "Pay period was successfully updated.", status: :see_other
        end
        format.turbo_stream do
          load_calendar_presenter
          render :update
        end
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /pay_periods/1
  def destroy
    set_pay_period
    @pay_period.destroy!
    respond_to do |format|
      format.html do
        redirect_to pay_periods_url, notice: "Pay period was successfully destroyed.", status: :see_other
      end
      format.turbo_stream do
        load_calendar_presenter
        render :destroy
      end
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  private def set_pay_period
    @pay_period = PayPeriod.find(params[:id])
  end

  private def set_calendar_start_date
    @calendar_start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.today
    @calendar_start_date = @calendar_start_date - @calendar_start_date.wday # Align to SUnday
    Rails.logger.warn("  *** set @calendar_start_date to #{@calendar_start_date.inspect}")
  end

  private def load_calendar_presenter
    set_calendar_start_date
    end_date = @calendar_start_date.advance(weeks: 12) - 1
    @calendar_presenter = PayPeriod::CalendarPresenter.new(
      start_date: @calendar_start_date,
      end_date: end_date,
      pay_periods: PayPeriod.inclusive_of_dates(@calendar_start_date, end_date).all
    )
  end

  # Only allow a list of trusted parameters through.
  private def pay_period_params
    params.require(:pay_period).permit(:start_date, :end_date)
  end
end
