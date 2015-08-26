require 'rails_helper'
require 'gumboot/shared_examples/roles'

RSpec.describe Role, type: :model do
  include_examples 'Roles'

  context '::for_entitlement' do
    let(:entitlement) { 'a:b:c' }

    def run
      Role.for_entitlement(entitlement)
    end

    subject { -> { run } }

    context 'when the role exists' do
      let!(:role) { create(:role, entitlement: entitlement) }
      it { is_expected.not_to change(Role, :count) }

      it 'returns the existing role' do
        expect(run).to eq(role)
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
    end
  end
end
