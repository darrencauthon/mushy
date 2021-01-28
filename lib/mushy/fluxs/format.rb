module Mushy

  class Format < Flux

    def self.details
      {
        name: 'Format',
        description: 'Return the event passed to it. This opens the opportunity to further alter results.',
        config: {},
      }
    end

    def process event, config
      event
    end

  end

end
