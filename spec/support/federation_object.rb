RSpec.shared_examples 'a federation object' do
  context 'when all objects are active' do
    before do
      2.times { create :activation, federation_object: subject }
    end

    it '#active should invoke all objects' do
      expect(described_class).to respond_to :active
      expect(described_class.active.all.count).to eq(1)
    end
  end

  context 'when some objects are inactive' do
    before do
      2.times { create :activation, federation_object: subject }
    end

    it '#active should invoke all objects' do
      expect(described_class).to respond_to :active
      expect(described_class.active.all.count).to eq(1)
    end
  end

  context 'when all objects are inactive' do
    before do
      2.times do
        create :activation, :deactivated,
               federation_object: subject
      end
    end

    it '#active should find only active objects' do
      expect(described_class.active.count).to eq(0)
    end
  end
end
