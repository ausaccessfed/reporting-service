# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :api_subject_roles, dependent: :destroy
  has_many :api_subjects, through: :api_subject_roles, dependent: :destroy

  has_many :subject_roles, dependent: :destroy
  has_many :subjects, through: :subject_roles, dependent: :destroy

  has_many :permissions, dependent: :destroy

  valhammer

  def self.for_entitlement(entitlement)
    create_with(name: 'auto').find_or_create_by!(entitlement:).tap(&:update_permissions)
  end

  def update_permissions
    return update_admin_permissions if admin_entitlements?
    return update_object_permissions if entitlement_suffix

    permissions.destroy_all
  end

  private

  def admin_entitlements?
    return false unless config[:admin_entitlements]

    config[:admin_entitlements].include? entitlement
  end

  def update_admin_permissions
    ensure_permission_values('*')
  end

  def update_object_permissions
    parts = entitlement_suffix.split(':', 3)

    return update_object_admin_permissions(parts) if parts[2] == 'admin'

    values = ["objects:#{parts[0]}:#{parts[1]}:read", "objects:#{parts[0]}:#{parts[1]}:report"]
    ensure_permission_values(values)
  end

  def update_object_admin_permissions(parts)
    ensure_permission_values("objects:#{parts[0]}:#{parts[1]}:*")
  end

  def ensure_permission_values(values)
    Array(values).each { |v| permissions.find_or_create_by!(value: v) }
    permissions.where.not(value: values).destroy_all
  end

  def entitlement_suffix
    prefix = config[:federation_object_entitlement_prefix]
    return nil unless entitlement.start_with?("#{prefix}:")

    i = prefix.length + 1
    entitlement[i..]
  end

  def config
    Rails.application.config.reporting_service.ide
  end
end
