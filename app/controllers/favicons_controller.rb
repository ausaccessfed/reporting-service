# frozen_string_literal: true

class FaviconsController < ApplicationController
  skip_before_action :ensure_authenticated

  def show
    public_action
    redirect_to view_context.image_path('favicon.ico')
  end
end
