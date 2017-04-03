# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  let(:user) { nil }
  subject { response }

  before do
    session[:subject_id] = user.try(:id)
    run
  end

  context '#index' do
    def run
      get :index
    end

    it { is_expected.to redirect_to('/auth/login') }

    context 'when authenticated' do
      let(:user) { create(:subject) }

      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template('dashboard/index') }
    end
  end
end
