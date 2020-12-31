module Mushy

  class Workflow
    attr_accessor :id
    attr_accessor :steps

    def initialize
      self.id = SecureRandom.uuid
      self.steps = []
    end

    def steps_for event
      steps
        .select { |x| x.parent_steps.any? { |y| y.id == event.step_id } }
        .flatten
    end
  end

end