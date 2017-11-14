# frozen_string_literal: true

class SubjectRole < ApplicationRecord
  belongs_to :subject
  belongs_to :role

  valhammer

  validates :role, uniqueness: { scope: :subject }
end
