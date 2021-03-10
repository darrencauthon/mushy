require 'csv'

module Mushy

  class ServiceFlux < Flux

    def start
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
      puts 'start'
      seconds_in_a_minute = 60
      puts config.inspect
      puts config
      sleep 5
      puts 'stop'
      {
      }
    end

  end

end