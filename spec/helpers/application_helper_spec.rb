# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#permitted?' do
    let(:user) { create(:subject, :authorized, permission: 'a:b:c') }

    before { assign(:subject, user) }

    it 'returns true when permitted' do
      expect(helper).to be_permitted('a:b:c')
    end

    it 'returns false when not permitted' do
      expect(helper).not_to be_permitted('a:b:d')
    end

    context 'with no user' do
      let(:user) { nil }

      it 'returns false' do
        expect(helper).not_to be_permitted('a:b:c')
      end
    end
  end

  describe '#environment_string' do
    let(:string) { Faker::Lorem.sentence }

    it 'returns the configured string' do
      expect(Rails.application).to receive_message_chain(:config, :reporting_service, :environment_string).and_return(
        string
      )

      expect(helper.environment_string).to eq(string)
    end
  end
end
