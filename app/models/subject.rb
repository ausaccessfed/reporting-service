# frozen_string_literal: true
class Subject < ActiveRecord::Base
  include Accession::Principal

  has_many :subject_roles
  has_many :roles, through: :subject_roles

  has_many :permissions_alias, through: :roles,
                               class_name: 'Permission',
                               source: :permissions

  has_many :automated_report_subscriptions

  valhammer

  def permissions
    permissions_alias.map(&:value)
  end

  def functioning?
    enabled? && complete?
  end

  def entitlements=(values)
    assigned = values.map do |value|
      Role.for_entitlement(value).tap do |r|
        roles << r unless roles.include?(r)
      end
    end

    subject_roles.where.not(role: assigned).destroy_all
  end
end
