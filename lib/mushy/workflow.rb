require 'json'

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

    def self.parse data
      data = JSON.parse data
      workflow = new

      workflow.steps = (data['steps'] || []).map do |record|
        step = Mushy::Step.new
        step.id = record['id']
        step.config = record['config']
        step
      end

      workflow
    end

  end

end