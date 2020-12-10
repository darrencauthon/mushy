module Mushy

  class Runner

    attr_accessor :runner

    def initialize
      self.runner = self
    end

    def start event_data, step, workflow
      run = find_run step, workflow
      event = build_event event_data, workflow.id, run.id
      events = run_event_and_step event, step
      events.each { |e| runner.run_event e }
      run
    end

    def run_event_and_step event, step
      [step.execute(event)]
        .flatten
        .reject { |x| x.nil? }
        .map { |x| x.is_a?(Hash) ? build_event(x, event.workflow_id, event.run_id) : x }
    end

    def find_run step, workflow
      run = Mushy::Run.new
      run.id = SecureRandom.uuid
      run.workflow_id = workflow.id
      run
    end

    def build_event event_data, workflow_id, run_id
      event = Mushy::Event.new
      event.id = SecureRandom.uuid
      event.run_id = run_id
      event.workflow_id = workflow_id
      event.data = event_data
      event
    end

  end

  class Run
    attr_accessor :id
    attr_accessor :workflow_id
  end

  class Workflow
    attr_accessor :id
  end

  class Step
    def execute event
    end
  end

  class Event
    attr_accessor :id
    attr_accessor :run_id
    attr_accessor :workflow_id
    attr_accessor :data
  end

end