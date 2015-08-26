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

  def entitlements=(values)
    assigned = values.map do |value|
      Role.for_entitlement(value).tap { |r| roles << r }
    end

    subject_roles.where.not(role: assigned).destroy_all
  end
end
