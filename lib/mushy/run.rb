module Mushy

  class Run

    attr_accessor :id
    attr_accessor :workflow_id

    def self.start event, step, workflow
      run = Run.new
      run.id = SecureRandom.uuid
      run.workflow_id = workflow.id
      run
    end

  end

  class Workflow

    attr_accessor :id

  end

end