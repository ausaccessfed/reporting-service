require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
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

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('welcome/index') }

    context 'when authenticated' do
      let(:user) { create(:subject) }

      context ':request.url is not a session' do
        before do
          session.delete(:request_url)
          get :index
        end

        it { is_expected.to redirect_to(dashboard_path) }
      end

      context ':request.url is a session' do
        before do
          session[:request_url] = '/public_reports/federation_growth'
          get :index
        end

        it { is_expected.to redirect_to('/public_reports/federation_growth') }
      end
    end
  end
end
