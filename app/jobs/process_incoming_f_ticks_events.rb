# frozen_string_literal: true

class ProcessIncomingFTicksEvents
  def perform
    FederatedLoginEvent.transaction do
      incoming_events.find_each { |event| (create_instance(event) && event.destroy!) || event.discard! }
    end
  end

  private

  def create_instance(event)
    subject = FederatedLoginEvent.new
    subject.create_instance(event)
  end

  def incoming_events
    IncomingFTicksEvent.where('discarded != ? AND created_at <= ?', true, Time.zone.now)
  end
end
