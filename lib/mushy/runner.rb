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
        events = events.map do |event|
                              result = runner.run_event_in_flow(event, flow)

                              return result[0] unless result[1]

                              result[0].flatten
                            end
      end

      run
    end

    def run_event_in_flow(event, flow)
      fluxes = flow.fluxs_for(event)

      [fluxes.map do |flux|
        events = runner.run_event_with_flux event, flux, flow

        return [events, false] if flux.is_a?(Mushy::Stop)

        events
      end.flatten, true]
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