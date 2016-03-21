class ProcessIncomingFTicksEvents
  def perform
    generate_instances
  end

  private

  def generate_instances
    FederatedLoginEvent.transaction do
      incoming_f_ticks_events.each do |incoming|
        data = incoming.data
        subject = FederatedLoginEvent.new

        incoming.destroy! if subject.create_instance(data)
        incoming.update!(discarded: true) unless subject.create_instance(data)
      end
    end
  end

  def incoming_f_ticks_events
    IncomingFTicksEvent.where.not(discarded: true)
  end
end
