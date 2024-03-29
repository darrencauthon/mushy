module Mushy
  class RegexMatches < Flux
    def self.details
      {
        name: 'RegexMatches',
        title: 'Find regex matches',
        description: 'Use a regex to search content.',
        fluxGroup: { name: 'Regex' },
        config: {
          regex: { description: 'The regular expression to use.',
                   type: 'text',
                   value: '(\w+)' },
          value: { description: 'The value against which to use the regular expression.',
                   type: 'text',
                   value: '{{value}}' }
        },
        examples: {
          'Simple Example' => {
                                description: 'The simplest regex.',
                                input: { text: 'apple orange' },
                                config: {
                                  regex: '(\w+)',
                                  value: 'apple orange'
                                },
                                result: [ { match1: 'apple' }, { match2: 'orange' } ]
                              },
          'Named Parameters' => {
                         description: 'Named Parameters.',
                         input: {
                                  text: 'apple 1 orange 2'
                                },
                         config: {
                                   regex: '(?&lt;name&gt;\w+) (?&lt;count&gt;\d+)',
                                   value: '{{text}}'
                                 },
                         result: [ { name: 'apple', count: '1' }, { name: 'orange', count: '2' } ]
                       },
                  }
    }
    end

    def process(_, config)
      return [] unless config[:value]
      return [] if (config[:regex] || '').strip == ''

      keys = config[:regex].scan(/\?<(\w+)>/).flatten

      regex = Regexp.new config[:regex]

      config[:value].scan(regex).map do |match|
        convert_the_match_to_a_hash match, keys
      end
    end

    def convert_the_match_to_a_hash(match, keys)
      {}.tap do |hash|
        match.each_with_index do |item, index|
          key = (keys[index] || "match#{index + 1}").to_sym
          hash[key] = item
        end
      end
    end
  end
end
