module Mushy

  class Runner

    attr_accessor :runner

    def initialize runner = nil
      self.runner = runner || self
    end

    def start event_data, step, workflow
      run = find_run step, workflow
      starting_event = build_event event_data, workflow.id, run.id, step.id

      events = run_event_with_step starting_event, step

      while events.any?
        events = events.map { |e| runner.run_event_in_workflow e, workflow }.flatten
      end

      run
    end

    def run_event_in_workflow event, workflow
      workflow.steps_for(event)
        .map { |s| runner.run_event_with_step event, s }
        .flatten
    end

    def run_event_with_step event, step
      [step.execute(event.data)]
        .flatten
        .reject { |x| x.nil? }
        .map { |x| x.is_a?(Hash) ? build_event(x, event.workflow_id, event.run_id, step.id) : x }
    end

    def find_run step, workflow
      run = Mushy::Run.new
      run.id = SecureRandom.uuid
      run.workflow_id = workflow.id
      run
    end

    def build_event event_data, workflow_id, run_id, step_id
      event = Mushy::Event.new
      event.id = SecureRandom.uuid
      event.run_id = run_id
      event.workflow_id = workflow_id
      event.step_id = step_id
      event.data = event_data
      event
    end

  end

end