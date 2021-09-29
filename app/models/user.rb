class User < ApplicationRecord
  acts_as_token_authenticatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :trackable

  has_one :role_info, class_name: 'UserRoleInfo', foreign_key: 'user_id'
  has_many :user_organisations
  has_many :organisations, through: :user_organisations
  has_many :admin_org, class_name: "Organisation", foreign_key: 'created_by_id'
  has_many :user_trackers, -> { order('created_at DESC') && where('created_at >= ?', (Time.now - 1.month)) }

  def as_json(options={})
    options[:methods] = [:full_name]
    super
  end

  def full_name
    return "#{firstname} #{lastname}"
  end

  def is_admin
    self.role_info.is_admin
  end

  def is_consultant
    self.role_info.is_consultant
  end

end
