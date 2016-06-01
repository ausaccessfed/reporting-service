# frozen_string_literal: true
RSpec.shared_examples 'a field accepting the urlsafe base64 alphabet' do
  it { is_expected.to allow_value(SecureRandom.urlsafe_base64).for(field) }
  it { is_expected.not_to allow_value('abcdefg%').for(field) }
  it { is_expected.not_to allow_value("abcdefg\n").for(field) }
end
