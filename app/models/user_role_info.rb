class UserRoleInfo < ApplicationRecord

  belongs_to :user, optional: true
end
