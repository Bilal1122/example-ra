class User < ApplicationRecord
  acts_as_token_authenticatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :role_info, class_name: 'UserRoleInfo', foreign_key: 'user_id'
  has_many :user_organisations
  has_many :organisations, through: :user_organisations

  def full_name
    return "#{firstname} #{lastname}"
  end
end
