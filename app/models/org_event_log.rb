class OrgEventLog < ApplicationRecord
  # has_attached_file :attachment
  # has_attached_file :image

  belongs_to :task, optional: true
  belongs_to :organisation_tasks, optional: true

  # validates_attachment_content_type :attachment, content_type: /\Aimage\/.*\z/
  # validates_attachment_file_name :attachment, matches: [/png\z/, /jpe?g\z/]
end
