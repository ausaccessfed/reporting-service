# frozen_string_literal: true
require 'rails_helper'

RSpec.describe IncomingFTicksEvent, type: :model do
  subject { build(:incoming_f_ticks_event) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:data) }
  it { is_expected.to validate_presence_of(:ip) }
  it { is_expected.to validate_presence_of(:timestamp) }

  context '::discard!' do
    let!(:incoming_event) { create(:incoming_f_ticks_event) }

    it 'should set :discarded to true' do
      expect { incoming_event.discard! }
        .to change(incoming_event, :discarded).from(false).to(true)
    end
  end
end
