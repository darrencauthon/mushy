class Mushy::Web < Mushy::Flux
  def self.details
    {
      name: 'Web',
      title: 'Set up a web endpoint',
      description: '',
      fluxGroup: { name: '' },
      config: {
      },
      examples: {
      }
    }
  end

  def process(_, config)
  end
end
