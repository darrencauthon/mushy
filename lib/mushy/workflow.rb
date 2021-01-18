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

    def self.build_step record
      step = Object.const_get("Mushy::#{record[:type] || record['type'] || 'Step'}").new
      step.id = record[:id] || record['id'] || step.id
      step.config = SymbolizedHash.new(record[:config] || record['config'])
      step
    end

    def self.parse data
      data = JSON.parse data
      workflow = new

      data_steps = data['steps'] || []

      workflow.steps = data_steps.map { |s| build_step s }

      steps_with_parent_ids = workflow.steps.reduce({}) { |t, i| t[i.id] = []; t }
      data_steps.map { |r| steps_with_parent_ids[r['id']] = r['parent_steps'] || [] }

      workflow.steps.each do |step|
        step.parent_steps = workflow.steps.select { |x| steps_with_parent_ids[step.id].include?(x.id) }
      end

      workflow
    end

  end

end