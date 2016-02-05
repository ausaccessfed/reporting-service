class AutomatedReportsController < ApplicationController
  def index
    public_action

    @reports = '*'
  end
end
