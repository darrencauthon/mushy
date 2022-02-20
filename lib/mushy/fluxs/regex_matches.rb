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

    def process(_, config)
      return [] unless config[:value]

      matches = config[:value].scan /(\w+)/
      matches.map do |match|
        { match: match[0] }
      end
    end
  end
end
