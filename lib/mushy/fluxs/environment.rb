module Mushy
  
  class Environment < Flux

    def self.details
      {
        name: 'Environment',
        description: 'Pull environment variables.',
        config: {
          variables: {
                       description: 'Map the environment variables to a new event.',
                       type:        'keyvalue',
                       value:       {},
                     },
        },
      }
    end

    def process event, config
      config[:variables].reduce({}) do |t, i|
        t[i[0]] = ENV[i[1]]
        t
      end
    end

  end

end
