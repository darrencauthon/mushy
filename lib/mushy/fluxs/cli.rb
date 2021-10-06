module Mushy
  
  class Cli < Flux

    def self.details
      {
        name: 'Cli',
        description: 'Accept CLI arguments from the run command.',
        config: {
        },
      }
    end

    def process event, config
      puts event.inspect
      event
    end

  end

end