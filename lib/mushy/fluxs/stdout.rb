module Mushy
  
  class Stdout < Flux

    def self.details
      {
        name: 'Stdout',
        title: 'Export text to stdout',
        fluxGroup: { name: 'Environment' },
        description: 'Standard Out',
        config: {
          message: {
                     description: 'The message to display.',
                     type:        'text',
                     value:       '{{message}}',
                   },
        },
      }
    end

    def process event, config
      puts config[:message]
      event
    end

  end

end