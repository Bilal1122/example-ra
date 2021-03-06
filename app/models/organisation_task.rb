class OrganisationTask < ApplicationRecord
  before_save :setDates

  belongs_to :organisation
  belongs_to :task
  has_one :org_event_log

  def task_info
    task = self.task
    return {
      id: task.id,
      title: task.title,
      description: task.description,
      task_type: task.task_type,
    }
  end

  def log_event
    log = self.org_event_log
    return false if log.blank?
    return {
      id: log.id,
      title: log.title,
      description: log.description,
      attachment: log.attachment,
      data: JSON.parse(log.data),
      created_at: log.created_at,
      task_id: log.task_id
    }
  end

  def task_status
    start_at = self.start_at
    end_at = self.end_at
    task_type = self.task.task_type
    date_now = Date.current
    return "completed" if self.status === "completed"
    case task_type
    when "once"
      "open"
    when "daily"
      if Time.now > (end_at.end_of_day - 3.hours)
        "ending"
      elsif Time.now > (end_at.end_of_day - 5.hours)
        "ending_soon"
      else
        "open"
      end
    when "weekly", "by_weekly", "monthly"
      if date_now >= end_at.to_date
        "ending"
      elsif date_now > (end_at - 3.days)
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
      self.end_at = Date.current.end_of_day
    when "weekly"
      next_week_start = (Date.current + 1.week).beginning_of_week
      self.start_at = next_week_start
      self.end_at = next_week_start.end_of_week(:friday)
    when "by_weekly"
      self.start_at = Date.current
      self.end_at = Date.current + 2.week > Date.current.end_of_month ? Date.current.end_of_month : (Date.current + 2.week).end_of_week(:friday)
    when "monthly"
      self.start_at = Date.current
      self.end_at = Date.current.end_of_month(:friday)
    else
    end
  end
end
