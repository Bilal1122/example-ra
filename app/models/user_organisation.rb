class UserOrganisation < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :organisation, optional: true

end
