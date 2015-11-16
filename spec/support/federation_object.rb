RSpec.shared_examples 'a federation object' do
  before do
    create :activation, federation_object: subject
  end

  it 'should respond to #active' do
    expect(subject.activations.count).to eq(1)
  end
end
