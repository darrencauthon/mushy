module Mushy
  class RegexMatches < Flux
    def self.details
      {
        name: 'RegexMatches',
        title: 'Find regex matches',
        description: 'Use a regex to search content.',
        fluxGroup: { name: 'Regex' },
        config: {
          matches: { description: '',
                     type: 'keyvalue',
                     shrink: true,
                     value: {} }
        },
        examples: {
        }
      }
    end

    def process(_, config)
      return [] unless config[:value]
      #(?<name>\w+) (?<count>\d+)

      matches = config[:value].scan Regexp.new(config[:regex])
      matches.map do |match|
        match.each_with_index.reduce({}) { |t, i| t["match#{i[1] + 1}".to_sym] = i[0]; t }
      end
    end
  end
end
