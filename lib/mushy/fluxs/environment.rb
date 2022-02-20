module Mushy
  
  class Environment < Flux

    def self.details
      {
        name: 'Environment',
        title: 'Pull environment variables',
        description: 'Pull environment variables.',
        fluxGroup: { name: 'Environment' },
        config: {
          variables: {
                       description: 'Map the environment variables to a new event.',
                       type:        'keyvalue',
                       value:       {},
                     },
        },
        examples: {
          "Example" => {
                         description: 'Get environmental variables.',
                         config: {
                                   variables: { text_domain: 'TEXTDOMAIN' }
                                 },
                         result: {
                                   text_domain: 'Linux-PAM',
                                 }
                       },
        }
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
