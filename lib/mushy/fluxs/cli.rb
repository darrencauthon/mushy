class Mushy::Cli < Mushy::Flux
  def self.details
    {
      name: 'Cli',
      title: 'Start a flow via command line',
      fluxGroup: { name: 'Starters', position: 0 },
      description: 'Accept CLI arguments from the run command.',
      config: {
      },
      examples: {
        'Calling From The Command Line' => {
          description: 'Calling the CLI with command-line arguments.',
          input: 'mushy start file first:John last:Doe',
          result: {
            first: 'John',
            last: 'Doe'
          }
        }
      }
    }
  end

  def process(event, _)
    event
  end
end
