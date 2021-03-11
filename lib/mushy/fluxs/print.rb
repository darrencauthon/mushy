module Mushy

  class Print < Flux

    def self.details
      {
        name: 'Print',
        description: 'Print output to the screen.',
        config: {
          message: {
                  description: 'The message to display',
                  type:        'text',
                  value:       '',
                },
        }
      }
    end

    def process event, config
      puts config[:message]
      {}
    end

  end

end