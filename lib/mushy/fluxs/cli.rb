module Mushy
  
  class Cli < Flux

    def self.details
      {
        name: 'Cli',
        title: 'Command Line Interface',
        description: 'Accept CLI arguments from the run command.',
        config: {
        },
        examples: {
          "Calling From The Command Line" => {
                                               description: 'Calling the CLI with command-line arguments.',
                                               input: "mushy start file first:John last:Doe",
                                               result: {
                                                         "first": "John",
                                                         "last": "Doe"
                                                       }
                                             },
          }
      }
    end

    def process event, config
      puts event.inspect
      event
    end

  end

end