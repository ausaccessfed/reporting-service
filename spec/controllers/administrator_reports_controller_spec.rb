require 'rails_helper'

RSpec.describe AdministratorReportsController, type: :controller do
  let(:user) { nil }
  subject { response }

  before do
    session[:subject_id] = user.try(:id)
    run
  end

  describe '#index' do
    def run
      get :index
    end

    context 'when user is not administrator' do
      let(:user) { create :subject }

      it { is_expected.to have_http_status('403') }
    end

    context 'when user is administrator' do
      let(:user) { create :subject, :authorized, permission: 'admin:*' }

      it { is_expected.to have_http_status(:ok) }
    end
  end
end
