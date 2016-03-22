class ProcessIncomingFTicksEvents
  def perform
    FederatedLoginEvent.transaction do
      incoming_events.find_each do |event|
        if perform_create_instance(event)
          event.destroy
        else
          event.update(discarded: true)
        end
      end
    end
  end

  private

  def perform_create_instance(event)
    subject = FederatedLoginEvent.new
    subject.create_instance(event)
  end

  def incoming_events
    IncomingFTicksEvent
      .where('discarded != ? AND created_at <= ?', true, Time.zone.now)
  end
end
