class OrgEventLog < ApplicationRecord
  # has_attached_file :attachment

  # validates_attachment_content_type :attachment, content_type: /\Aimage\/.*\z/
  # validates_attachment_file_name :attachment, matches: [/png\z/, /jpe?g\z/]
end
