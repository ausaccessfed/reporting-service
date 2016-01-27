class AdministratorReportsController < ApplicationController
  def index
    check_access! 'admin:*'
  end
end
