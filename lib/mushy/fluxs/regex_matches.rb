module Mushy
  class RegexMatches < Flux
    def self.details
      {
        name: 'RegexMatches',
        title: 'Find regex matches',
        description: 'Use a regex to search content.',
        fluxGroup: { name: 'Regex' },
        config: {
        },
        examples: {
        }
      }
    end

    def process(_, _)
      [{ match: 'apple' }, { match: 'orange' }, { match: 'banana' }]
    end
  end
end
