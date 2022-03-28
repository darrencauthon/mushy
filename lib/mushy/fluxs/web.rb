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

  def process(event, _)
    puts event.inspect
    puts 'method!!!' if event[:method]
    event
  end
end
