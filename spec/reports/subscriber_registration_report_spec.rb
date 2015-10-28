require 'rails_helper'

RSpec.describe SubscriberRegistrationReport do
  let(:header) { [['Name', 'Registration Date']] }
  let(:type) { 'subscriber-registrations' }

  let(:activated_organization) { create(:organization) }
  let(:activated_idp) { create(:identity_provider) }
  let(:activated_sp) { create(:service_provider) }
  let(:activated_rapid_connect) { create(:rapid_connect_service) }

  let(:org_report) do
    SubscriberRegistrationReport.new('organizations')
  end

  let(:idp_report) do
    SubscriberRegistrationReport.new('identity_providers')
  end

  let(:sp_report) do
    SubscriberRegistrationReport.new('service_providers')
  end

  let(:rapid_c_report) do
    SubscriberRegistrationReport.new('rapid_connect_services')
  end

  let(:service_report) do
    SubscriberRegistrationReport.new('services')
  end

  context '#rows' do
    before do
      create(:activation,
             federation_object: activated_organization)
    end

    it 'must return array' do
      expect(org_report.rows).to be_an(Array)
    end

    it 'must include related object activated_at' do
      activated_date = activated_organization.activations
                       .order(activated_at: :asc).first.activated_at

      org_name = activated_organization.name

      expect(org_report.rows.map)
        .to include([org_name, activated_date])
    end
  end

  context '#rows on services' do
    before do
      create(:activation,
             federation_object: activated_sp)
      create(:activation,
             federation_object: activated_rapid_connect)
    end

    it 'must return array' do
      expect(service_report.rows).to be_an(Array)
    end

    it 'must include related object activated_at' do
      sp_activated_date = activated_sp.activations
                          .order(activated_at: :asc).first.activated_at
      rapid_activated_date = activated_rapid_connect.activations
                             .order(activated_at: :asc).first.activated_at

      sp_service_name = activated_sp.name
      rapid_service_name = activated_rapid_connect.name

      expect(service_report.rows.map)
        .to include([sp_service_name, sp_activated_date])

      expect(service_report.rows.map)
        .to include([rapid_service_name, rapid_activated_date])
    end
  end

  context '#generate' do
    it 'must have title, header and type' do
      title = 'Registered Organizations'
      expect(org_report.generate).to include(title: title,
                                             header: header, type: type)
    end

    it 'must have title, header and type' do
      title = 'Registered Identity Providers'
      expect(idp_report.generate).to include(title: title,
                                             header: header, type: type)
    end

    it 'must have title, header and type' do
      title = 'Registered Service Providers'
      expect(sp_report.generate).to include(title: title,
                                            header: header, type: type)
    end

    it 'must have title, header and type' do
      title = 'Registered Rapid Connect Services'
      expect(rapid_c_report.generate).to include(title: title,
                                                 header: header, type: type)
    end

    it 'must have title, header and type' do
      title = 'Registered Services'
      expect(service_report.generate).to include(title: title,
                                                 header: header, type: type)
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
    let(:deactivated_organization) { create(:organization) }

    before do
      create(:activation,
             federation_object: activated_organization)
      create(:activation, :deactivated,
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
    let(:deactivated_idp) { create(:identity_provider) }

    before do
      create(:activation,
             federation_object: activated_idp)
      create(:activation, :deactivated,
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
    let(:deactivated_sp) { create(:service_provider) }

    before do
      create(:activation,
             federation_object: activated_sp)
      create(:activation, :deactivated,
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
    let(:deactivated_rapid_connect) { create(:rapid_connect_service) }

    before do
      create(:activation,
             federation_object: activated_rapid_connect)
      create(:activation, :deactivated,
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

  context '#select_activated_subscribers servcies' do
    let(:deactivated_rapid_connect) { create(:rapid_connect_service) }
    let(:deactivated_sp) { create(:service_provider) }

    before do
      create(:activation,
             federation_object: activated_sp)
      create(:activation, :deactivated,
             federation_object: deactivated_sp)

      create(:activation,
             federation_object: activated_rapid_connect)
      create(:activation, :deactivated,
             federation_object: deactivated_rapid_connect)
    end

    it 'should include activated_sp' do
      expect(service_report.select_activated_subscribers)
        .to include(activated_sp)
    end

    it 'should include activated_rapid_connect' do
      expect(service_report.select_activated_subscribers)
        .to include(activated_rapid_connect)
    end

    it 'should not include deactivated_' do
      expect(service_report.select_activated_subscribers)
        .not_to include(deactivated_sp)
    end

    it 'should not include deactivated_rapid_connect' do
      expect(service_report.select_activated_subscribers)
        .not_to include(deactivated_rapid_connect)
    end
  end
end
