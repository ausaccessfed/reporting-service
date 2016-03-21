class ProcessIncomingFTicksEvents
  def perform
    FederatedLoginEvent.transaction do
      incoming_events.find_each do |event|
        create_instances(event)
      end
    end
  end

  private

  def create_instances(event)
    subject = FederatedLoginEvent.new
    subject.create_instance(event) || event.update!(discarded: true)
  end

  def incoming_events
    IncomingFTicksEvent.where.not(discarded: true)
  end
end
