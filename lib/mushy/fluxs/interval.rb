require 'csv'

module Mushy

  class ServiceFlux < Flux
  end

  class Interval < ServiceFlux

    def self.setup
      {
        seconds: ->(x) { x },
        minutes: ->(x) { x * 60 },
        hours:   ->(x) { x * 60 * 60 },
        days:    ->(x) { x * 60 * 60 * 24 },
        weeks:   ->(x) { x * 60 * 60 * 24 * 7 },
      }
    end

    def self.details
      {
        name: 'Minutely',
        description: 'Fire an event every X minutes.',
        config: {},
      }.tap do |c|
        setup.keys.each do |key|
          c[:config][key] = {
                              description: "#{key.to_s.capitalize} until the job is fired again.",
                              type:        'integer',
                              shrink:       true,
                              value:       '',
                            }
        end
      end
    end

    def start &block
      block.call
      sleep time
    end

    def time
      the_time = self.class.setup.keys
                      .select { |x| config[x].to_s != '' }
                      .map    { |x| self.class.setup[x].call(config[x].to_i) }
                      .sum

      the_time > 0 ? the_time : 60
    end

    def process event, config
      puts time
      {
        time: time
      }
    end

  end

end