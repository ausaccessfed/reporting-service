require 'rails_helper'

RSpec.describe SubscriberRegistrationReport do
  let(:title) { Faker::Lorem.sentence }
  let(:header) { [['Name', 'Registration Date']] }
  let(:footer) { [['Name', 'Registration Date']] }
  let(:type) { 'subscriber-registrations' }

  let(:activated_organization) { create(:organization) }
  let(:activated_idp) { create(:identity_provider) }
  let(:activated_sp) { create(:service_provider) }
  let(:activated_rapid_connect) { create(:rapid_connect_service) }

  let(:org_report) do
    SubscriberRegistrationReport.new(title, 'organizations')
  end

  let(:idp_report) do
    SubscriberRegistrationReport.new(title, 'identity_providers')
  end

  let(:sp_report) do
    SubscriberRegistrationReport.new(title, 'service_providers')
  end

  let(:rapid_c_report) do
    SubscriberRegistrationReport.new(title, 'rapid_connect_services')
  end

  context '#rows' do
    it 'must return array' do
      expect(org_report.rows).to be_an(Array)
    end

    it 'must include first' do
      puts org_report.rows
    end
  end

  context '#generate' do
    it 'must have title, header and type' do
      expect(org_report.generate).to include(title: title, header: header,
                                             footer: footer, type: type)
    end

    it 'must have title, header and type' do
      expect(idp_report.generate).to include(title: title, header: header,
                                             footer: footer, type: type)
    end

    it 'must have title, header and type' do
      expect(sp_report.generate).to include(title: title, header: header,
                                            footer: footer, type: type)
    end

    it 'must have title, header and type' do
      expect(rapid_c_report.generate).to include(title: title, header: header,
                                                 footer: footer, type: type)
    end
  end

  context '#subscribers_list' do
    it 'should to match Organization.all' do
      expect(org_report.subscribers_list)
        .to match_array(Organization.all)
    end

    it 'should to match IdentityProvider.all' do
      expect(idp_report.subscribers_list)
        .to match_array(IdentityProvider.all)
    end

    it 'should to match ServiceProvider.all' do
      expect(sp_report.subscribers_list)
        .to match_array(ServiceProvider.all)
    end

    it 'should to match RapidConnectService.all' do
      expect(rapid_c_report.subscribers_list)
        .to match_array(RapidConnectService.all)
    end
  end

  context '#select_activated_subscribers organizations' do
    let(:deactivated_organization) do
      create(:organization)
    end

    let!(:activation) do
      create(:activation, :with_activated_at,
             federation_object: activated_organization)
    end

    let!(:deactivation) do
      create(:activation, :with_deactivated_at,
             federation_object: deactivated_organization)
    end

    it 'should include organization' do
      expect(org_report.select_activated_subscribers)
        .to include(activated_organization)
    end

    it 'should not include deactivated_organization' do
      expect(org_report.select_activated_subscribers)
        .not_to include(deactivated_organization)
    end
  end

  context '#select_activated_subscribers idps' do
    let(:deactivated_idp) do
      create(:identity_provider)
    end

    let!(:activation) do
      create(:activation, :with_activated_at,
             federation_object: activated_idp)
    end

    let!(:deactivation) do
      create(:activation, :with_deactivated_at,
             federation_object: deactivated_idp)
    end

    it 'should include activated_idp' do
      expect(idp_report.select_activated_subscribers)
        .to include(activated_idp)
    end

    it 'should not include deactivated_idp' do
      expect(idp_report.select_activated_subscribers)
        .not_to include(deactivated_idp)
    end
  end

  context '#select_activated_subscribers sps' do
    let(:deactivated_sp) do
      create(:service_provider)
    end

    let!(:activation) do
      create(:activation, :with_activated_at,
             federation_object: activated_sp)
    end

    let!(:deactivation) do
      create(:activation, :with_deactivated_at,
             federation_object: deactivated_sp)
    end

    it 'should include activated_sp' do
      expect(sp_report.select_activated_subscribers)
        .to include(activated_sp)
    end

    it 'should not include deactivated_sp' do
      expect(sp_report.select_activated_subscribers)
        .not_to include(deactivated_sp)
    end
  end

  context '#select_activated_subscribers rapid_connect_services' do
    let(:deactivated_rapid_connect) do
      create(:rapid_connect_service)
    end

    let!(:activation) do
      create(:activation, :with_activated_at,
             federation_object: activated_rapid_connect)
    end

    let!(:deactivation) do
      create(:activation, :with_deactivated_at,
             federation_object: deactivated_rapid_connect)
    end

    it 'should include activated_rapid_connect' do
      expect(rapid_c_report.select_activated_subscribers)
        .to include(activated_rapid_connect)
    end

    it 'should not include deactivated_rapid_connect' do
      expect(rapid_c_report.select_activated_subscribers)
        .not_to include(deactivated_rapid_connect)
    end
  end
end
