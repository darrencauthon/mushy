require 'csv'

module Mushy

  class ServiceFlux < Flux

    def self.start
    end

  end

  class Minutely < ServiceFlux

    def self.details
      {
        name: 'Minutely',
        description: 'Fire an event every X minutes.',
        config: {
        },
      }
    end

    def process event, config
    end

  end

end