class ProcessIncomingFTicksEvents
  def perform
    FederatedLoginEvent.transaction do
      IncomingFTicksEvent.find_each do |event|
        create_instances(event) unless event.discarded.eql? true
      end
    end
  end

  private

  def create_instances(event)
    subject = FederatedLoginEvent.new
    subject.create_instance(event) || event.update!(discarded: true)
  end
end
