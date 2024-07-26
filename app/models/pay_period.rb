class PayPeriod < ApplicationRecord
  validates :start_date, presence: true
  validates :end_date, presence: true, comparison: { greater_than_or_equal_to: :start_date }
  validate :pay_period_does_not_overlap_existing_periods

  scope :before_date, ->(date){ where("end_date <= :date", date: date) }
  scope :after_date, ->(date){ where("start_date >= :date", date: date) }
  scope :inclusive_of_dates, ->(start_date, end_date){ where("end_date >= :start_date AND start_date <= :end_date", start_date: start_date, end_date: end_date) }

  def start_time
    start_date.beginning_of_day
  end

  def end_time
    end_date.end_of_day
  end

  def update_and_correct_adjacent_pay_periods(new_attribs)
    saved = false

    PayPeriod.transaction do
      assign_attributes(new_attribs)
      # First we delete any periods that have been subsumed by the change
      PayPeriod.where("start_date >= :start_date AND end_date <= :end_date AND id != :id", start_date: start_date, end_date: end_date, id: id).delete_all

      # Second we load any remaining affected periods, and change their dates
      in_scope_periods = PayPeriod.inclusive_of_dates([start_date, start_date_was].min - 1, [end_date, end_date_was].max + 1).where.not(id: self.id)
      in_scope_periods.each do |pay_period|
        if pay_period.start_date < start_date
          pay_period.assign_attributes(end_date: start_date - 1)
        elsif pay_period.end_date > end_date
          pay_period.assign_attributes(start_date: end_date + 1)
        end
      end

      # Last, we check our results. We save without validating, to bypass the
      # pay_period_does_not_overlap_existing_periods validation, then re-check validity before closing the transaction
      in_scope_periods.collect{|pp| pp.save(validate: false) }
      save(validate: false)
      if in_scope_periods.all?(&:valid?) && valid?
        saved = true
      else
        in_scope_periods.each{|pp| puts "#{pp.start_date} - #{pp.end_date} #{pp.errors.inspect}" }
        raise ActiveRecord::TransactionRollbackError
      end
    end
    saved
  end

  private def pay_period_does_not_overlap_existing_periods
    query_scope = PayPeriod
    query_scope = query_scope.where.not(id: self.id) if persisted?
    if query_scope.inclusive_of_dates(start_date, start_date).any?
      errors.add(:start_date, "can't be included in another pay period")
    end
    if query_scope.inclusive_of_dates(end_date, end_date).any?
      errors.add(:end_date, "can't be included in another pay period")
    end
  end
end
