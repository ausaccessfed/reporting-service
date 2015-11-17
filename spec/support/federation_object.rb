RSpec.shared_examples 'a federation object' do
  context 'when all objects are active' do
    before do
      5.times { create :activation, federation_object: subject }
    end

    it 'should respond to #active' do
      expect(described_class).to respond_to :active
      expect(described_class.active.count).to eq(5)
    end
  end

  context 'when all objects are deactivated' do
    before do
      2.times do
        create :activation, federation_object: subject
      end

      2.times do
        create :activation, :deactivated,
               federation_object: subject
      end
    end

    it 'should respond to #active' do
      expect(described_class).to respond_to :active
      expect(described_class.active.count).to eq(2)
    end
  end
end
