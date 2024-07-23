# frozen_string_literal: true

require 'redis'

module RapidRack
  RSpec.describe RedisRegistry do
    let(:overrides) { Module.new }

    subject do
      klass = Class.new
      klass.send(:extend, described_class)
      klass.send(:extend, overrides)
    end

    context '#register_jti' do
      let(:value) { 'abcd' }

      it 'returns true for a new jti' do
        expect(subject.register_jti(value)).to be_truthy
      end

      it 'returns false for a previously seen jti' do
        subject.register_jti(value)
        expect(subject.register_jti(value)).to be_falsey
      end
    end
  end
end
