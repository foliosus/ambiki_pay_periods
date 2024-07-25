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
