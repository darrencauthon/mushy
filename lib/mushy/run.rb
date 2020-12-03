module Mushy

  class Run

    attr_accessor :id
    attr_accessor :workflow_id

    def self.start event, step, workflow
      events = step.execute event
      events.each { |e| EventRunner.run e }

      run = find_run event, step, workflow
      event.run_id = run.id
      run
    end

    def self.find_run event, step, workflow
      run = Mushy::Run.new
      run.id = SecureRandom.uuid
      run.workflow_id = workflow.id
      run
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
    attr_accessor :run_id
  end

end