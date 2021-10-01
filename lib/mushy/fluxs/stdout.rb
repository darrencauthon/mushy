module Mushy
  
  class Stdout < Flux

    def self.details
      {
        name: 'Stdout',
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
      nil
    end

  end

end