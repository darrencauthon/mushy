module Mushy

  class Runner

    attr_accessor :runner

    def initialize runner = nil
      self.runner = runner || self
    end

    def start event_data, flux, workflow
      run = find_run flux, workflow
      starting_event = build_event event_data, workflow.id, run.id, flux.id

      events = run_event_with_flux starting_event, flux

      while events.any?
        events = events.map { |e| runner.run_event_in_workflow e, workflow }.flatten
      end

      run
    end

    def run_event_in_workflow event, workflow
      workflow.fluxs(event)
        .map { |s| runner.run_event_with_flux event, s }
        .flatten
    end

    def run_event_with_flux event, flux
      [flux.execute(event.data)]
        .flatten
        .reject { |x| x.nil? }
        .map { |x| x.is_a?(Hash) ? build_event(x, event.workflow_id, event.run_id, flux.id) : x }
    end

    def find_run flux, workflow
      run = Mushy::Run.new
      run.id = SecureRandom.uuid
      run.workflow_id = workflow.id
      run
    end

    def build_event event_data, workflow_id, run_id, flux_id
      event = Mushy::Event.new
      event.id = SecureRandom.uuid
      event.run_id = run_id
      event.workflow_id = workflow_id
      event.flux_id = flux_id
      event.data = event_data
      event
    end

  end

end