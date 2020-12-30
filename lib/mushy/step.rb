module Mushy

  class Step
    def execute event
      puts event.inspect
    end
  end

end