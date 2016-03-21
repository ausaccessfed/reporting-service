class ProcessIncomingFTicksEvents
  def perform
    generate_instances
  end

  private

  def generate_instances
    FederatedLoginEvent.transaction do
      incoming_f_ticks_events.each do |incoming|
        subject = FederatedLoginEvent.new

        if subject.create_instance(incoming.data)
          incoming.destroy!
        else
          incoming.update!(discarded: true)
        end
      end
    end
  end

  def incoming_f_ticks_events
    IncomingFTicksEvent.where.not(discarded: true)
  end
end
