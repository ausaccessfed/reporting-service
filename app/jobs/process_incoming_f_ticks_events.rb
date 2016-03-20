class ProcessIncomingFTicksEvents
  def perform
    generate_instances
  end

  private

  def generate_instances
    incoming_f_ticks_events.each do |incoming_event|
      data = incoming_event.data
      subject = FederatedLoginEvent.new

      subject.generate_record(data)
    end
  end

  def incoming_f_ticks_events
    IncomingFTicksEvent.where.not(discarded: true)
  end
end
