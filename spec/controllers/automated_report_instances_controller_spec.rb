require 'rails_helper'

RSpec.describe AutomatedReportInstancesController, type: :controller do
  let(:user) { create :subject }

  REPORT_CLASSES_WITH_NIL_TARGET =
    %w(DailyDemandReport
       FederatedSessionsReport
       FederationGrowthReport
       IdentityProviderAttributesReport).freeze

  REPORT_CLASSES_WITH_NIL_TARGET.each_with_index do |klass, i|
    let!("instance_#{i}".to_sym) do
      create :automated_report_instance,
             automated_report: (create :automated_report,
                                       report_class: klass)
    end
  end

  def get_tamplate_name(type)
    type.chomp('Report').underscore.tr('_', '-')
  end

  def run(identifier)
    get :show, identifier: identifier
  end

  before do
    session[:subject_id] = user.try(:id)
  end

  describe 'get on /automated_reports' do
    it 'should response with 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'assigns the report data correctly' do
      AutomatedReportInstance.all.each do |instance|
        run(instance.identifier)

        report_class = instance.automated_report.report_class
        data = JSON.parse(assigns[:data], symbolize_names: true)
        template = get_tamplate_name(report_class)

        expect(assigns[:data]).to be_a(String)
        expect(data[:type]).to eq(template)
      end
    end
  end
end
