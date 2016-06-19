# frozen_string_literal: true
require 'rails_helper'
require 'gumboot/shared_examples/subjects'

RSpec.describe Subject, type: :model do
  include_examples 'Subjects'

  context 'permissions' do
    RSpec::Matchers.define(:be_permitted) do |action|
      match { |subject| subject.permits?(action) }
    end

    context 'super admin' do
      subject! { create(:subject, :authorized, permission: '*') }
      it { is_expected.to be_permitted('admin:subjects:list') }
    end

    context 'specific permission' do
      subject! { create(:subject, :authorized, permission: 'a:b:c') }
      it { is_expected.to be_permitted('a:b:c') }
      it { is_expected.not_to be_permitted('a:b') }
    end
  end

  context '#entitlements=' do
    def run
      object.entitlements = entitlements
    end

    def roles
      object.subject_roles(true).map(&:role)
    end

    let(:object) { create(:subject) }
    let(:entitlements) { ['a:b:c'] }

    context 'when the role exists' do
      let!(:role) { create(:role, entitlement: 'a:b:c') }

      it 'does not create a role' do
        expect { run }.not_to change(Role, :count)
      end

      it 'assigns the role to the subject' do
        expect { run }.to change { roles }.to include(role)
      end

      context 'when the role is already assigned' do
        before { object.roles << role }

        it 'makes no change' do
          expect { run }.not_to change { roles }
        end
      end
    end

    context 'when the role does not exist' do
      it 'creates the role' do
        expect { run }.to change(Role, :count).by(1)
        expect(Role.last).to have_attributes(entitlement: 'a:b:c')
      end

      it 'assigns the new role to the subject' do
        expect { run }.to change { roles }
          .to contain_exactly(an_instance_of(Role))
        expect(roles).to include(Role.last)
      end
    end

    context 'when an entitlement is removed' do
      let(:entitlements) { [] }
      let!(:role) { create(:role, entitlement: 'a:b:c') }
      let!(:subject_role) { object.subject_roles.create!(role: role) }

      it 'removes the role' do
        expect { run }.to change { roles }.to be_empty
      end
    end
  end
end
