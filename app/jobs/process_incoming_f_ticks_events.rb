class ProcessIncomingFTicksEvents
  def perform
    FederatedLoginEvent.transaction do
      incoming_events.find_each do |event|
        perform_create_instance(event)
      end
    end
  end

  private

  def perform_create_instance(event)
    subject = FederatedLoginEvent.new
    subject.create_instance(event) || event.update(discarded: true)
  end

  def incoming_events
    IncomingFTicksEvent
      .where('discarded != ? AND created_at <= ?', true, Time.zone.now)
  end
end
