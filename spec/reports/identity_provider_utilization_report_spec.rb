# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentityProviderUtilizationReport do
  let(:type) { 'identity-provider-utilization' }
  let(:header) { [%w[Name Sessions]] }
  let(:title) { 'Identity Provider Utilization Report' }

  subject { IdentityProviderUtilizationReport.new(start, finish, 'DS') }

  context 'Service Provider Utilization report #Generate' do
    let(:object_type) { :identity_provider }
    let(:target) { :selected_idp }

    it_behaves_like 'Utilization Report'
  end
end
