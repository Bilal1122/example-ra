class Organisation < ApplicationRecord
  
  has_many :user_organisations
  has_many :consultants, through: :user_organisations, source: :user
  has_many :organisation_tasks
  has_many :tasks, through: :organisation_tasks, source: :task
  has_one  :admin, class_name: 'User', foreign_key: :created_by_id

  # scope :admin, -> { User.find_by(id: self.created_by_id) }

  def as_json(options={})
    options[:methods] = [:created_by]
    super
  end

  def created_by
    User.find_by(id: self.created_by_id)
  end
end
