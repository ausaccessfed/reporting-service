RSpec.shared_examples 'a federation object' do
  context '#active' do
    let(:object) do
      create factory
    end

    context 'when all objects are active' do
      before do
        2.times do
          create :activation, federation_object: subject
          create :activation, federation_object: object
        end
      end

      it 'should invoke all objects' do
        expect(described_class.active.all)
          .to contain_exactly(subject, object)
      end
    end

    context 'when some objects are inactive' do
      before do
        2.times { create :activation, federation_object: subject }
      end

      before do
        2.times do
          create :activation, :deactivated,
                 federation_object: object
        end
      end

      it 'should invoke all objects' do
        expect(described_class.active.all)
          .to contain_exactly(subject)

        expect(described_class.active.all)
          .not_to include(object)
      end
    end

    context 'when all objects are inactive' do
      before do
        2.times do
          create :activation, :deactivated,
                 federation_object: subject

          create :activation, :deactivated,
                 federation_object: object
        end
      end

      it 'should find only active objects' do
        expect(described_class.active.all).not_to include(subject)
        expect(described_class.active.all).not_to include(object)
      end
    end
  end
end
