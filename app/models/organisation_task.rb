class OrganisationTask < ApplicationRecord
  before_save :setDates

  belongs_to :organisation
  belongs_to :task

  def task_info
    task = self.task
    return {
      id: task.id,
      title: task.title,
      description: task.description,
      task_type: task.task_type,
    }
  end

  def task_status
    start_at = self.start_at
    end_at = self.end_at
    task_type = self.task.task_type
    date_now = Date.current
    case task_type
    when "once"
      "open"
    when "daily"
      if Time.now > (end_at.to_time.end_of_day - 3.hours)
        "ending_soon"
      else
        "open"
      end
    when "weekly", "by_weekly", "monthly"
      if date_now > (end_at - 2.days)
        "ending_soon"
      else 
        "open"
      end
    else
      "open"
    end
  end

  private
  def setDates
    case self.task.task_type
    when "once"
      self.start_at = Date.current
    when "daily"
      self.start_at = Date.current
      self.end_at = Date.current
    when "weekly"
      self.start_at = Date.current
      self.end_at = Date.current + 1.week
    when "by_weekly"
      self.start_at = Date.current
      self.end_at = Date.current + 2.week
    when "monthly"
      self.start_at = Date.current
      self.end_at = Date.current + 1.month
    else
    end
  end
end