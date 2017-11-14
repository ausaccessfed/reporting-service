# frozen_string_literal: true

class APISubject < ApplicationRecord
  include Accession::Principal

  has_many :api_subject_roles, dependent: :destroy
  has_many :roles, through: :api_subject_roles, dependent: :destroy

  valhammer
  validates :x509_cn, format: { with: /\A[\w-]+\z/ }

  def permissions
    roles.flat_map { |role| role.permissions.map(&:value) }
  end

  def functioning?
    enabled?
  end
end
