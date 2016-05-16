class APISubjectRole < ActiveRecord::Base
  belongs_to :api_subject
  belongs_to :role
end
