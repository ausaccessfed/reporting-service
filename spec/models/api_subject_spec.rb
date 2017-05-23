# frozen_string_literal: true

require 'rails_helper'
require 'gumboot/shared_examples/api_subjects'

RSpec.describe APISubject, type: :model do
  include_examples 'API Subjects'

  context 'permissions' do
    RSpec::Matchers.define(:be_permitted) do |action|
      match { |subject| subject.permits?(action) }
    end

    context 'super admin' do
      subject! { create(:api_subject, :authorized, permission: '*') }
      it { is_expected.to be_permitted('admin:subjects:list') }
    end

    context 'specific permission' do
      subject! { create(:api_subject, :authorized, permission: 'a:b:c') }
      it { is_expected.to be_permitted('a:b:c') }
      it { is_expected.not_to be_permitted('a:b') }
    end
  end
end
