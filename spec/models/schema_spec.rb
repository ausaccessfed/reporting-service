# frozen_string_literal: true

require 'rails_helper'
require 'gumboot/shared_examples/database_schema'

RSpec.describe 'Database Schema' do
  let(:connection) { ActiveRecord::Base.connection.raw_connection }

  include_context 'Database Schema'
end
