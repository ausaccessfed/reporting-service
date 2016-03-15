require 'rails_helper'

RSpec.describe IncomingFTicksEvent, type: :model do
  subject { build(:incoming_f_ticks_event) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:data) }
  it { is_expected.to validate_presence_of(:ip) }
  it { is_expected.to validate_presence_of(:timestamp) }
end
