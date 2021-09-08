class Task < ApplicationRecord

  extend Enumerize
  enumerize :task_type, in: [:once, :daily, :weekly, :by_weekly, :monthly]

end
