require 'csv'

module Mushy
  
  class ReadJson < Flux

    def self.details
      {
        name: 'ReadJson',
        description: 'Read JSON and output it as an event.',
        config: {
          json: {
                  description: 'The JSON contents that will be returned as an event.',
                  type:        'text',
                  value:       'json',
                },
        },
      }
    end

    def process event, config
      JSON.parse config[:json]
    end

  end

end