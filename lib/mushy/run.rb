module Mushy

  class Run

    attr_accessor :id

    def self.start event, step, workflow
      run = Run.new
      run.id = SecureRandom.uuid
      run
    end

  end

end