module Mushy

  class Format < Flux

    def self.details
      {
        name: 'Format',
        description: 'Return the event passed to it. This opens the opportunity to use the common fluxing to alter the event.',
        config: {},
        examples: {
          "Example" => {
                         description: 'It only returns what is passed to it.',
                         input: {
                                  hello: 'world',
                                },
                         config: {
                                 },
                         result: {
                                   hello: 'world',
                                 }
                       },
        }
      }
    end

    def process event, config
      event
    end

  end

end
