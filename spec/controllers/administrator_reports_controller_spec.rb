require 'rails_helper'

RSpec.describe AdministratorReportsController, type: :controller do
  let(:user) { create :subject, :authorized, permission: 'admin:*' }
  subject { response }

  before { session[:subject_id] = user.try(:id) }

  def run_get
    get action
  end

  def run_post
    post action, params
  end

  shared_examples 'an admin report' do
    before do
      run_get
      run_post
    end

    it 'Assigns report data to template' do
      expect(assigns[:data]).to be_a(String)
      data = JSON.parse(assigns[:data], symbolize_names: true)
      expect(data[:type]).to eq(template)
    end
  end

  context '#index' do
    before { get :index }

    context 'when user is not administrator' do
      let(:user) { create :subject }
      it { is_expected.to have_http_status('403') }
    end

    context 'when user is administrator' do
      it { is_expected.to have_http_status(:ok) }
    end
  end

  context 'generate Subscriber Registrations Report' do
    let(:params) { { identifier: 'organizations' } }
    let(:template) { 'subscriber-registrations' }
  end

  context 'generate Federation Growth Report' do
    let(:params) { { start: Time.now.utc, end: Time.now.utc - 1.month } }
    let(:template) { 'federation-growth' }
  end

  context 'generate Daily Demand Report' do
    let(:params) { { start: Time.now.utc, end: Time.now.utc - 1.month } }
    let(:template) { 'daily-demand' }
  end
end
