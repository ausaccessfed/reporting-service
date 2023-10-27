# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WelcomeController do
  subject { response }

  let(:user) { nil }


  before do
    session[:subject_id] = user.try(:id)
    run
  end

  describe '#index' do
    def run
      get :index
    end

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('welcome/index') }

    context 'when authenticated' do
      let(:user) { create(:subject) }

      it { is_expected.to redirect_to(dashboard_path) }
    end
  end
end
