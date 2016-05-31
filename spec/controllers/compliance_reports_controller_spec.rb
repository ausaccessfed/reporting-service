# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ComplianceReportsController, type: :controller do
  let(:user) { create(:subject) }
  before { session[:subject_id] = user.try(:id) }

  def run_get
    get route_path
  end

  def run_post
    post route_path, "#{finder}": object.send(finder)
  end

  shared_examples 'get request for provider object' do
    let!(:object) { create object_type }
    let!(:activation) { create(:activation, federation_object: object) }

    context 'with no user' do
      let(:user) { nil }

      it 'requires authentication' do
        run_get
        expect(response).to redirect_to('/auth/login')
      end
    end

    it 'renders the page' do
      run_get
      expect(response).to have_http_status(:ok)
      expect(response).to render_template("compliance_reports#{template}")
    end

    it 'assigns the objects' do
      run_get
      expect(assigns[:objects_list]).to include(object)
    end

    it 'excludes inactive objects' do
      activation.update!(deactivated_at: 1.second.ago.utc)
      run_get
      expect(assigns[:objects_list]).not_to include(object)
    end
  end

  shared_examples 'post request for provider object' do
    let!(:object) { create object_type }
    let!(:activation) { create(:activation, federation_object: object) }
    let(:finder) { :entity_id }

    it 'renders the page' do
      run_post
      expect(response).to have_http_status(:ok)
      expect(response).to render_template("compliance_reports#{template}")
    end

    it 'assigns the objects' do
      run_post
      expect(assigns[:objects_list]).to include(object)
    end

    it 'assigns the attribute entity_id' do
      run_post
      expect(assigns[finder]).to eq(object.send(finder))
    end

    it 'assigns the report data' do
      run_post
      expect(assigns[:data]).to be_a(String)
      data = JSON.parse(assigns[:data], symbolize_names: true)
      expect(data[:type]).to eq(cache_type)
    end
  end

  describe 'get & post on /service_provider/compatibility_report' do
    let(:object_type) { :service_provider }
    let(:route_path) { :service_provider_compatibility_report }
    let(:cache_type) { 'service-compatibility' }
    let(:template) { '/service_provider_compatibility_report' }

    it_behaves_like 'post request for provider object'
    it_behaves_like 'get request for provider object'
  end

  describe 'get on /identity_provider/attributes_report' do
    let(:object_type) { :identity_provider }
    let(:route_path) { :identity_provider_attributes_report }
    let(:template) { '/identity_provider_attributes_report' }

    it_behaves_like 'get request for provider object'
  end

  shared_examples 'post request for attribute object' do
    let!(:object) { create :saml_attribute }
    let(:finder) { :name }

    it 'renders the page' do
      run_post
      expect(response).to have_http_status(:ok)
      expect(response).to render_template("compliance_reports#{template}")
    end

    it 'assigns the objects' do
      run_post
      expect(assigns[:objects_list]).to include(object)
    end

    it 'assigns the attribute name' do
      run_post
      expect(assigns[finder]).to eq(object.send(finder))
    end

    it 'assigns the report data' do
      run_post
      expect(assigns[:data]).to be_a(String)
      data = JSON.parse(assigns[:data], symbolize_names: true)
      expect(data[:type]).to eq(cache_type)
    end
  end

  shared_examples 'get request for attribute object' do
    let!(:object) { create :saml_attribute }
    let(:saml_attributes) { SAMLAttribute.all }
    context 'with no user' do
      let(:user) { nil }

      it 'requires authentication' do
        run_get
        expect(response).to redirect_to('/auth/login')
      end
    end

    it 'renders the page' do
      run_get
      expect(response).to have_http_status(:ok)
      expect(response).to render_template("compliance_reports#{template}")
    end

    it 'assigns the objects' do
      run_get
      expect(assigns[:objects_list]).to match_array(saml_attributes)
    end
  end

  describe 'post on /attribute/identity_providers_report' do
    let(:route_path) { :attribute_identity_providers_report }
    let(:cache_type) { 'provided-attribute' }
    let(:template) { '/attribute_identity_providers_report' }

    it_behaves_like 'post request for attribute object'
  end

  describe 'get on /attribute/identity_providers_report' do
    let(:route_path) { :attribute_identity_providers_report }
    let(:cache_type) { 'provided-attribute' }
    let(:template) { '/attribute_identity_providers_report' }

    it_behaves_like 'get request for attribute object'
  end

  describe 'post on /attribute/service_providers_report' do
    let(:route_path) { :attribute_service_providers_report }
    let(:cache_type) { 'requested-attribute' }
    let(:template) { '/attribute_service_providers_report' }

    it_behaves_like 'post request for attribute object'
  end

  describe 'get on /attribute/service_providers_report' do
    let(:route_path) { :attribute_service_providers_report }
    let(:cache_type) { 'requested-attribute' }
    let(:template) { '/attribute_service_providers_report' }

    it_behaves_like 'get request for attribute object'
  end
end
