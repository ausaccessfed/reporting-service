# frozen_string_literal: true

require 'rails_helper'
require 'gumboot/shared_examples/roles'

RSpec.describe Role, type: :model do
  include_examples 'Roles'

  let(:admin) { 'a:b:c:admin' }
  let(:admin_reporting) { 'a:b:c:reporting' }
  let(:prefix) { 'a:b:c' }
  let(:admin_entitlements) { [admin, admin_reporting] }
  let(:config) do
    { admin_entitlements: admin_entitlements,
      federation_object_entitlement_prefix: prefix }
  end

  before do
    allow(Rails.application.config.reporting_service).to receive(:ide)
      .and_return(config)
  end

  context '::for_entitlement' do
    let(:entitlement) { 'a:b:c' }

    def run
      Role.for_entitlement(entitlement)
    end

    subject { -> { run } }

    context 'when admin_entitlements is missing ' do
      let(:admin_entitlements) { nil }
      let!(:role) { create(:role, entitlement: entitlement) }
      it { is_expected.not_to change(Role, :count) }

      it 'returns the existing role' do
        expect(run).to eq(role)
      end

      it 'updates the permissions' do
        expect_any_instance_of(Role)
          .to receive(:update_permissions).and_call_original
        run
      end
    end

    context 'when the role exists' do
      let!(:role) { create(:role, entitlement: entitlement) }
      it { is_expected.not_to change(Role, :count) }

      it 'returns the existing role' do
        expect(run).to eq(role)
      end

      it 'updates the permissions' do
        expect_any_instance_of(Role)
          .to receive(:update_permissions).and_call_original
        run
      end
    end

    context 'when the role does not exist' do
      it { is_expected.to change(Role, :count).by(1) }

      it 'returns the new role' do
        result = run
        expect(result).to eq(Role.last)
        expect(result).to have_attributes(name: 'auto',
                                          entitlement: entitlement)
      end

      it 'updates the permissions' do
        expect_any_instance_of(Role)
          .to receive(:update_permissions).and_call_original
        run
      end
    end
  end

  context '#update_permissions' do
    def run
      subject.update_permissions
    end

    def permission_values
      subject.permissions.reload.map(&:value)
    end

    context 'for an admin entitlement' do
      subject { create(:role, entitlement: admin) }

      it 'creates a superuser permission' do
        expect { run }.to change { permission_values }.to contain_exactly('*')
      end

      it 'removes non-superuser permissions' do
        subject.permissions.create!(value: 'unnecessary')
        subject.reload

        expect { run }.to change { permission_values }.to contain_exactly('*')
      end

      it 'creates no duplicate permissions' do
        run
        expect { run }.not_to change(Permission, :count)
      end
    end

    context 'for an admin with reporting entitlement' do
      subject { create(:role, entitlement: admin_reporting) }

      it 'creates a admin reporting permission' do
        expect { run }.to change { permission_values }.to contain_exactly('*')
      end

      it 'removes non-superuser permissions' do
        subject.permissions.create!(value: 'unnecessary')
        subject.reload

        expect { run }.to change { permission_values }.to contain_exactly('*')
      end

      it 'creates no duplicate permissions' do
        run
        expect { run }.not_to change(Permission, :count)
      end
    end

    context 'for a federation object admin entitlement' do
      let(:type) { SecureRandom.urlsafe_base64 }
      let(:sha1) { SecureRandom.hex(20) }

      # e.g. $prefix:organization:da39a3ee5e6b4b0d3255bfef95601890afd80709:admin
      subject { create(:role, entitlement: "#{prefix}:#{type}:#{sha1}:admin") }

      it 'creates the object admin permission' do
        expect { run }.to change { permission_values }
          .to contain_exactly("objects:#{type}:#{sha1}:*")
      end

      it 'removes extra permissions' do
        subject.permissions.create!(value: 'unnecessary')
        subject.reload

        expect { run }.to change { permission_values }
          .to contain_exactly("objects:#{type}:#{sha1}:*")
      end

      it 'creates no duplicate permissions' do
        run
        expect { run }.not_to change(Permission, :count)
      end
    end

    context 'for a federation object entitlement' do
      let(:type) { SecureRandom.urlsafe_base64 }
      let(:sha1) { SecureRandom.hex(20) }

      # e.g. $prefix:organization:da39a3ee5e6b4b0d3255bfef95601890afd80709
      subject { create(:role, entitlement: "#{prefix}:#{type}:#{sha1}") }

      it 'creates the object permission' do
        expect { run }.to change { permission_values }
          .to contain_exactly("objects:#{type}:#{sha1}:read",
                              "objects:#{type}:#{sha1}:report")
      end

      it 'removes extra permissions' do
        subject.permissions.create!(value: 'unnecessary')
        subject.reload

        expect { run }.to change { permission_values }
          .to contain_exactly("objects:#{type}:#{sha1}:read",
                              "objects:#{type}:#{sha1}:report")
      end

      it 'creates no duplicate permissions' do
        run
        expect { run }.not_to change(Permission, :count)
      end
    end

    context 'for an unrecognised entitlement' do
      let(:type) { SecureRandom.urlsafe_base64 }
      let(:sha1) { SecureRandom.hex(20) }

      subject { create(:role, entitlement: 'a:b:c') }

      it 'creates no permissions' do
        run
        expect(permission_values).to be_empty
      end

      it 'removes all permissions' do
        subject.permissions.create!(value: 'unnecessary')
        subject.reload

        expect { run }.to change { permission_values }.to be_empty
      end
    end
  end
end
