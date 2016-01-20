require 'rails_helper'

RSpec.describe SubscriberReportsController do
  describe 'get /subscriber_reports' do
    subject { { get: '/subscriber_reports' } }
    it { is_expected.to route_to 'subscriber_reports#index' }
  end
end
