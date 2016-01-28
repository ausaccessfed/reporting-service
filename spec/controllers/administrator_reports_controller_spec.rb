require 'rails_helper'

RSpec.describe AdministratorReportsController, type: :controller do
  let(:user) { create :subject, :authorized, permission: 'admin:*' }
  subject { response }

  before do
    session[:subject_id] = user.try(:id)
    run
  end

  def run
    get :index
  end

  def run_post
    post :subscriber_registrations_report,
         identifier: 'organizations'
  end

  describe '#index' do
    context 'when user is not administrator' do
      let(:user) { create :subject }
      it { is_expected.to have_http_status('403') }
    end

    context 'when user is administrator' do
      it { is_expected.to have_http_status(:ok) }
    end

    context 'generate report' do
      it 'Assigns report data to template' do
        run_post
        expect(assigns[:data]).to be_a(String)
        data = JSON.parse(assigns[:data], symbolize_names: true)
        expect(data[:type]).to eq('subscriber-registrations')
      end
    end
  end
end
