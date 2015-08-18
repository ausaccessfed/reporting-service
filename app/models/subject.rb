class Subject < ActiveRecord::Base
  include Accession::Principal

  has_many :subject_roles
  has_many :roles, through: :subject_roles

  valhammer

  def permissions
    roles.flat_map { |r| r.permissions.map(&:value) }
  end

  def functioning?
    enabled? && complete?
  end
end
