class UserOrganisation < ApplicationRecord
  belongs_to :user, optional: true
end
