class ProcessIncomingFTicksEvents
  def perform
    create_instances
  end

  private

  def create_instances
    FederatedLoginEvent.transaction do
      incoming_f_ticks_events.each do |event|
        subject = FederatedLoginEvent.new

        subject.create_instance(event) || event.update!(discarded: true)
      end
    end
  end

  def incoming_f_ticks_events
    IncomingFTicksEvent.where.not(discarded: true)
  end
end
