# frozen_string_literal: true

class Subject < ApplicationRecord
  include Accession::Principal

  has_many :subject_roles, dependent: :destroy
  has_many :roles, through: :subject_roles, dependent: :destroy
  has_many :automated_report_subscriptions, dependent: :destroy

  valhammer

  def permissions
    roles.joins(:permissions).pluck('permissions.value')
  end

  def functioning?
    enabled? && complete?
  end

  def entitlements=(values)
    assigned = values.map { |value| Role.for_entitlement(value).tap { |r| roles << r unless roles.include?(r) } }

    subject_roles.where.not(role: assigned).destroy_all
  end
end
