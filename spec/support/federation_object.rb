# frozen_string_literal: true

RSpec.shared_examples 'a federation object' do
  describe '#active' do
    let(:object) { create(factory) }

    context 'when all objects are active' do
      before do
        2.times do
          create(:activation, federation_object: subject)
          create(:activation, federation_object: object)
        end
      end

      it 'includes all objects' do
        expect(described_class.active.all).to contain_exactly(subject, object)
      end
    end

    context 'when some objects are inactive' do
      before do
        2.times { create(:activation, federation_object: subject) }
        create_list(:activation, 2, :deactivated, federation_object: object)
      end

      it 'includes only active objects' do
        expect(described_class.active.all).to contain_exactly(subject)

        expect(described_class.active.all).not_to include(object)
      end
    end

    context 'when all objects are inactive' do
      before do
        2.times do
          create(:activation, :deactivated, federation_object: subject)

          create(:activation, :deactivated, federation_object: object)
        end
      end

      it 'includes no objects' do
        expect(described_class.active.all).not_to include(subject)
        expect(described_class.active.all).not_to include(object)
      end
    end
  end
end
