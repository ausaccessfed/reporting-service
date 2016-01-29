class SubjectRole < ActiveRecord::Base
  belongs_to :subject
  belongs_to :role

  valhammer

  validates :role, uniqueness: { scope: :subject }
end
