module Mushy

  class Run

    attr_accessor :id
    attr_accessor :workflow_id

    def self.start event_data, step, workflow
      run = find_run step, workflow
      event = build_event event_data, step, workflow, run
      events = step.execute event
      events.each { |e| EventRunner.run e }

      run
    end

    def self.find_run step, workflow
      run = Mushy::Run.new
      run.id = SecureRandom.uuid
      run.workflow_id = workflow.id
      run
    end

    def self.build_event event_data, step, workflow, run
      event = Mushy::Event.new
      event.id = SecureRandom.uuid
      event.run_id = run.id
      event.workflow_id = workflow.id
      event
    end

  end

  class Workflow
    attr_accessor :id
  end

  class Step
  end

  class EventRunner
  end

  class Event
    attr_accessor :id
    attr_accessor :run_id
    attr_accessor :workflow_id
  end

end