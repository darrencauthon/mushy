class Mushy::WebResponse < Mushy::Flux
  def self.details
    {
      name: 'WebResponse',
      title: 'Web Response',
      fluxGroup: { name: 'Stoppers', position: 1 },
      description: 'Return a web response',
      config: {
      }
    }
  end

  def process(event, _)
    event
  end

  def stop(event)
    {
      event: event
    }
  end
end
