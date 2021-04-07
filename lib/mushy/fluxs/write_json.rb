require 'csv'

module Mushy
  
  class WriteJson < Flux

    def self.details
      {
        name: 'WriteJson',
        description: 'Write the incoming event as JSON.',
        config: {
          key: {
                description: 'The key of the outgoing field that will contain the JSON.',
                type:        'text',
                value:       'json',
              },
        },
      }
    end

    def process event, config
      {
        config[:key] => event.to_json
      }
    end

  end

end