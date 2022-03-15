module Mushy

  class Runner

    attr_accessor :runner

    def initialize runner = nil
      self.runner = runner || self
    end

    def start event_data, flux, flow
      run = find_run flux, flow
      starting_event = build_event event_data, flow.id, run.id, flux.id

      events = run_event_with_flux starting_event, flux, flow

      while events.any?
        events = events.map { |e| runner.run_event_in_flow e, flow }.flatten
      end

      run
    end

    def run_event_in_flow event, flow
      flow.fluxs_for(event)
        .map do |flux|
          runner.run_event_with_flux event, flux, flow
        end.flatten
    end

    def run_event_with_flux event, flux, flow
      data = event.data
      data = flow.adjust_data data
      [flux.execute(data)]
        .flatten
        .reject { |x| x.nil? }
        .map { |x| x.is_a?(Hash) ? build_event(x, event.flow_id, event.run_id, flux.id) : x }
    end

    def find_run flux, flow
      run = Mushy::Run.new
      run.id = SecureRandom.uuid
      run.flow_id = flow.id
      run
    end

    def build_event event_data, flow_id, run_id, flux_id
      event = Mushy::Event.new
      event.id = SecureRandom.uuid
      event.run_id = run_id
      event.flow_id = flow_id
      event.flux_id = flux_id
      event.data = event_data
      event
    end

  end

end