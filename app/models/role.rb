class Role < ActiveRecord::Base
  has_many :api_subject_roles
  has_many :api_subjects, through: :api_subject_roles

  has_many :subject_roles
  has_many :subjects, through: :subject_roles

  has_many :permissions

  valhammer

  def self.for_entitlement(entitlement)
    create_with(name: 'auto').find_or_create_by!(entitlement: entitlement)
  end
end
