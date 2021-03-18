module Mushy

  class Times < Flux

    def self.details
      {
        name: 'Times',
        description: 'Return the event passed to it, X times.',
        config: {
          from: {
                  description: 'The number of times this event should be returned.',
                  type:        'integer',
                  value:       '1',
                },
        }
      }
    end

    def process event, config
      config[:times].times.each_with_index.map { |x, i| event.dup.tap { |e| e[:index] = i } }
    end

  end

end
