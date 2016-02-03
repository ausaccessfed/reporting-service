require 'rails_helper'

RSpec.describe AutomatedReportsController, type: :controller do
  let(:user) { create :subject }
  before do
    session[:subject_id] = user.try(:id)
    get :index
  end

  describe 'get on /automated_reports' do
    it 'should response with 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'should render the index tempplate' do
      expect(response).to render_template('index')
    end
  end
end
