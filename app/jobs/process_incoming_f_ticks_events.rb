class ProcessIncomingFTicksEvents
  def perform
    generate_instances
  end

  private

  def generate_instances
    FederatedLoginEvent.transaction do
      incoming_f_ticks_events.each do |incoming|
        subject = FederatedLoginEvent.new
        incoming.destroy! if subject.create_instance(incoming.data)
      end
    end

    incoming_f_ticks_events.each { |event| event.update! discarded: true }
  end

  def incoming_f_ticks_events
    IncomingFTicksEvent.where.not(discarded: true)
  end
end
