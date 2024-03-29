class Mushy::Environment < Mushy::Flux
  def self.details
    {
      name: 'Environment',
      title: 'Pull environment variables',
      description: 'Pull environment variables.',
      fluxGroup: { name: 'Environment' },
      config: {
        variables: {
          description: 'Map the environment variables to a new event.',
          type: 'keyvalue',
          value: {}
        }
      },
      examples: {
        'Example' => {
          description: 'Get environmental variables.',
          config: { variables: { text_domain: 'TEXTDOMAIN' } },
          result: { text_domain: 'Linux-PAM' }
        }
      }
    }
  end

  def process(_, config)
    config[:variables].each_with_object({}) { |t, i| t[i[0]] = ENV[i[1]] }
  end
end
