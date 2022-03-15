class Mushy::Stop < Mushy::Flux
  def self.details
    {
      name: 'Stop',
      title: 'Stopper',
      fluxGroup: { name: 'Stoppers', position: 1 },
      description: 'Stop the flow',
      config: {
      }
    }
  end

  def process(event, _)
    event
  end
end
