require 'rails_helper'

RSpec.describe IdentityProviderReportsController, type: :controller do
  let(:prefix) { 'identity' }

  include_examples 'a Subscriber Report'

  context 'Identity Provider Destination Services' do
    let(:report_path) { :destination_services_report }
    let(:template) { 'identity-provider-destination-services' }
    it_behaves_like 'Report Controller'
  end
end
