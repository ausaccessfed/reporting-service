# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HealthController, type: :controller do
  describe 'GET #show' do
    subject(:show) { get :show }

    context 'when db is accessible' do
      it 'returns http success' do
        show
        expect(response).to have_http_status(:success)
        expect(response.parsed_body.symbolize_keys).to match(
          hash_including({ version: 'VERSION_PROVIDED_ON_BUILD', db_active: true })
        )
      end
    end

    context 'when db is inaccessible via error' do
      before { allow(ActiveRecord::Base.connection).to receive(:current_database).and_throw(StandardError) }

      it 'returns http 503' do
        show
        expect(response).to have_http_status(:service_unavailable)
        expect(response.parsed_body.symbolize_keys).to match(hash_including({ db_active: false }))
      end
    end

    context 'when db is inaccessible' do
      before { allow(ActiveRecord::Base.connection).to receive(:current_database).and_return(database_name) }

      let(:database_name) { nil }

      it 'returns http 503' do
        show
        expect(response).to have_http_status(:service_unavailable)
        expect(response.parsed_body.symbolize_keys).to match(hash_including({ db_active: false }))
      end

      context 'when empty' do
        let(:database_name) { '' }

        it 'returns http 503' do
          show
          expect(response).to have_http_status(:service_unavailable)
          expect(response.parsed_body.symbolize_keys).to match(hash_including({ db_active: false }))
        end
      end
    end

    context 'when redis is inaccessible' do
      before { allow(HealthController).to receive(:redis).and_throw(StandardError) }

      it 'returns http 503' do
        show
        expect(response).to have_http_status(:service_unavailable)
        expect(response.parsed_body.symbolize_keys).to match(hash_including({ redis_active: false }))
      end
    end
  end
end
