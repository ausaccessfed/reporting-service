require 'rails_helper'

RSpec.describe ProcessIncomingFTicksEvents do
  let!(:incoming_f_tick_event) { create :incoming_f_ticks_event }

  subject { ProcessIncomingFTicksEvents.new }

  def run
    subject.perform
  end

  context 'Process IncomingFTicksEvents' do
    it 'should create an instance of FederatedLoginEvent' do
      expect { run }.to change(FederatedLoginEvent, :count).by(1)
    end
  end
end
