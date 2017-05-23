# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  context '#permitted?' do
    let(:user) { create(:subject, :authorized, permission: 'a:b:c') }

    before { assign(:subject, user) }

    it 'returns true when permitted' do
      expect(helper.permitted?('a:b:c')).to be_truthy
    end

    it 'returns false when not permitted' do
      expect(helper.permitted?('a:b:d')).to be_falsey
    end

    context 'with no user' do
      let(:user) { nil }

      it 'returns false' do
        expect(helper.permitted?('a:b:c')).to be_falsey
      end
    end
  end

  context '#environment_string' do
    let(:string) { Faker::Lorem.sentence }

    it 'returns the configured string' do
      expect(Rails.application)
        .to receive_message_chain(:config, :reporting_service,
                                  :environment_string)
        .and_return(string)

      expect(helper.environment_string).to eq(string)
    end
  end
end
