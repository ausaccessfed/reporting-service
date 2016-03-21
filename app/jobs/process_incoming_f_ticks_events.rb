class ProcessIncomingFTicksEvents
  def perform
    incoming_events.find_in_batches(batch_size: 100) do |event_group|
      create_instances(event_group)
    end
  end

  private

  def create_instances(event_group)
    FederatedLoginEvent.transaction do
      event_group.each do |event|
        subject = FederatedLoginEvent.new

        subject.create_instance(event) || event.update!(discarded: true)
      end
    end
  end

  def incoming_events
    IncomingFTicksEvent.where.not(discarded: true)
  end
end
