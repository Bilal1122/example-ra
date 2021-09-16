class Task < ApplicationRecord

  has_many :organisation_tasks

  extend Enumerize
  enumerize :task_type, in: [:once, :daily, :weekly, :by_weekly, :monthly]

  def as_json(options={})
    options[:methods] = [:created_by]
    super
  end

  def created_by
    User.find_by(id: self.created_by_id)
  end
end
