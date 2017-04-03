# frozen_string_literal: true

RSpec.shared_examples 'a Subscriber Report' do
  let(:organization) { create :organization }

  let(:object) do
    create "#{prefix}_provider".to_sym, organization: organization
  end

  let(:bad_object) { create "#{prefix}_provider".to_sym }

  let(:user) do
    create :subject, :authorized,
           permission:
           "objects:organization:#{organization.identifier}:report"
  end

  def run_get
    get report_path
  end

  def run_post
    post report_path,
         entity_id: object.entity_id,
         start: 1.year.ago.utc, end: Time.now.utc
  end

  before do
    session[:subject_id] = user.try(:id)
    create :activation, federation_object: object
    create :activation, federation_object: bad_object
  end

  shared_examples 'Report Controller' do
    context 'with no user' do
      let(:user) { nil }

      it 'requires authentication' do
        run_get
        expect(response).to redirect_to('/auth/login')
      end
    end

    context 'with user' do
      it 'assigns only permitted objects to the objects_list list' do
        run_get
        expect(assigns[:entities]).to include(object)
        expect(assigns[:entities]).not_to include(bad_object)
      end
    end

    context 'generate report' do
      it 'assigns only permitted objects to the objects_list' do
        run_post
        expect(assigns[:data]).to be_a(String)
        data = JSON.parse(assigns[:data], symbolize_names: true)
        expect(data[:type]).to eq(template)
      end
    end
  end

  context 'Sessions Report' do
    let(:report_path) { :sessions_report }
    let(:template) { "#{prefix}-provider-sessions" }

    it_behaves_like 'Report Controller'
  end

  context 'Daily Demand Report' do
    let(:report_path) { :daily_demand_report }
    let(:template) { "#{prefix}-provider-daily-demand" }

    it_behaves_like 'Report Controller'
  end

  context 'steps should scale correctly' do
    let(:params) { { entity_id: object.entity_id } }
    let(:path) { :sessions_report }

    it_behaves_like 'report with scalable steps'
  end
end
