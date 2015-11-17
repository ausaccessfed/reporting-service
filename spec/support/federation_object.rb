RSpec.shared_examples 'a federation object' do
  context 'when all objects are active' do
    before do
      5.times { create :activation, federation_object: subject }
    end

    it '#find_active should invoke all objects' do
      expect(described_class).to respond_to :find_active
      expect(described_class.find_active.count).to eq(5)
    end
  end

  context 'when some objects are deactivated' do
    before do
      2.times do
        create :activation, federation_object: subject
      end

      2.times do
        create :activation, :deactivated,
               federation_object: subject
      end
    end

    it '#find_active should find only active objects' do
      expect(described_class.find_active.count).to eq(2)
    end
  end
end
