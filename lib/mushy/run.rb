module Mushy

  class Run

    attr_accessor :id
    attr_accessor :workflow_id

    def self.start event, step, workflow
      events = step.execute event
      StepRunner.run events[0]

      run = Run.new
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

  class StepRunner
  end

  class Event
  end

end