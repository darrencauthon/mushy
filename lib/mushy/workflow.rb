module Mushy

  class Workflow
    attr_accessor :id
    attr_accessor :steps

    def steps_for event
      []
    end
  end

end