require 'rails_helper'

RSpec.describe ProcessIncomingFTicksEvents do
  subject { ProcessIncomingFTicksEvents.new }

  def run
    subject.perform
  end

  before do
    create_list :incoming_f_ticks_event, 10
    create_list :incoming_f_ticks_event, 10, data: 'invalid data'
  end

  context 'Process IncomingFTicksEvents' do
    it 'should create an instance of FederatedLoginEvent'\
       'and delete IncomingFTicksEvent' do
      expect { run }.to change(FederatedLoginEvent, :count).by(10)
        .and change(IncomingFTicksEvent, :count).by(-10)
    end

    it 'should set :discarded to true and keep the record if data is invalid' do
      run
      invalid_events = IncomingFTicksEvent
                       .where(data: 'invalid data', discarded: true)

      expect(IncomingFTicksEvent.all).to match_array(invalid_events)
    end

    it 'should not find any' do
      run
      events = IncomingFTicksEvent.where(discarded: true)
      expect(events.count).to eq(10)
    end
  end
end
