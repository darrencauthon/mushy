module Mushy

  class Times < Flux

    def self.details
      {
        name: 'Times',
        description: 'Return the event passed to it, X times.',
        config: {
          times: {
                   description: 'The number of times this event should be returned.',
                   type:        'integer',
                   value:       '1',
                 },
        },
        examples: {
          "Basic Example" => {
                               input: {name: "Elephant"},
                               config: {times: 2},
                               result: [ { name: "Elephant", index: 0 }, { name: "Elephant", index: 1 } ],
                              }
        }
      }
    end

    def process event, config
      config[:times]
        .to_i
        .times
        .each_with_index
        .map { |x, i| event.dup.tap { |e| e[:index] = i } }
    end

  end

end
