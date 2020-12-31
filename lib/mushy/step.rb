module Mushy

  class Step
    def execute event
    end
  end

  class ThroughStep
    def execute event
      event
    end
  end

end