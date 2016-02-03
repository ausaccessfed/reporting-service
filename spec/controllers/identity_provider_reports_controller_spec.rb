require 'rails_helper'
require 'controllers/subscriber_reports_controller'

RSpec.describe IdentityProviderReportsController, type: :controller do
  let(:prefix) { 'identity' }

  include_context 'a Subscriber Report'

  context 'Identity Provider Destination Services' do
    let(:report_path) { :destination_services_report }
    let(:template) { 'identity-provider-destination-services' }
    it_behaves_like 'Report Controller'
  end
end
