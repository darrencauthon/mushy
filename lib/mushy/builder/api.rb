require 'daemons'

module Mushy::Builder
end

module Mushy::Builder::Api
  def self.run(data)
    data = SymbolizedHash.new JSON.parse(data)

    event = SymbolizedHash.new JSON.parse(data[:setup][:event].to_json)

    config = SymbolizedHash.new data[:config]

    flux = Mushy::Flow.build_flux({ type: data[:setup][:flux], config: config })

    result = flux.execute event

    [result].flatten
  end

  def self.save(file, data)
    file = "#{file}.mushy" unless file.downcase.end_with?('.mushy')

    data = SymbolizedHash.new JSON.parse(data)
    Mushy::WriteFile.new.process({}, { name: file, data: JSON.pretty_generate(data) })
  end

  def self.start(file, event)
    original_file = file
    file = [file, "#{Dir.home}/.mushy/#{file}"]
             .map { |x| (x.downcase.end_with?('.mushy') ? x : "#{x}.mushy") }
             .select { |x| File.exist?(x) }
             .first

    unless file
      puts "#{original_file} does not exist."
      return
    end

    flow = File.open(file).read
    flow = Mushy::Flow.parse flow

    service_fluxes = flow.fluxs.select { |x| x.respond_to? :loop }

    pwd = Dir.pwd

    if service_fluxes.any?

      things = service_fluxes
          .map do |s|
            {
              flux: s,
              proc: lambda do |e|
                Dir.chdir(pwd)
                Mushy::Runner.new.start(e, s, flow)
              end,
              run_method: (s.config[:run_strategy] == 'daemon' ? :run_this_as_a_daemon : :run_this_inline)
            }
          end.group_by { |x| x[:run_method] }

      (things[:run_this_as_a_daemon] || [])
        .map { |p| -> { p[:flux].loop(&p[:proc]) } }
        .map { |x| -> { loop(&x) } }
        .map { |x| run_this_as_a_daemon(&x) }

      (things[:run_this_inline] || [])
        .map { |p| -> { p[:flux].loop(&p[:proc]) } }
        .map { |x| -> { loop(&x) } }
        .map { |x| run_this_inline(&x) }

      exit
    end

    web_flux = flow.fluxs.select { |x| x.is_a?(Mushy::Web) }.first
    if web_flux
      if event[:method]
        return Mushy::Runner.new.start event, web_flux, flow
      else
        return Mushy::FireUpAWebServer.new.tap do |x|
                x.id = SecureRandom.uuid
                x.flow_id = flow.id
                x.flow = flow
                x.flux = web_flux
              end
      end
    end

    cli_flux = flow.fluxs.select { |x| x.is_a?(Mushy::Cli) }.first

    Mushy::Runner.new.start event, cli_flux, flow
  end

  def self.run_this_inline(&block)
    block.call
  end

  def self.run_this_as_a_daemon(&block)
    Daemons.call(&block).pid.pid
  end

  def self.get_flow(file)
    file = "#{file}.mushy" unless file.downcase.end_with?('.mushy')
    data = JSON.parse File.open(file).read

    data['fluxs'] = standardize_these data['fluxs']
    data['fluxs'] = organize_as_a_flattened_tree_based_on_parents data['fluxs']

    data
  rescue
    { fluxs: [] }
  end

  def self.standardize_these(fluxs)
    fluxs
      .reject { |x| x['parents'] }
      .each   { |x| x['parents'] = [x['parent']].select { |y| y } }
    fluxs
      .select { |x| x['parent'] }
      .each   { |x| x.delete 'parent' }
    fluxs
      .select { |x| x['parents'] }
      .each   { |x| x['parents'] = x['parents'].select { |y| y } }

    fluxs
  end

  def self.organize_as_a_flattened_tree_based_on_parents(fluxs)
    fluxs = fluxs.sort_by { |x| x['parents'].count }

    new_fluxs = [fluxs.first]

    loop do
      next_fluxs = fluxs.select { |x| x['parents'].include? new_fluxs[-1]['id'] }

      unless next_fluxs.any?
        next_fluxs = [fluxs.reject { |x| new_fluxs.map { |y| y['id'] }.include?(x['id']) }[0]].select { |x| x }
      end

      new_fluxs = [new_fluxs, next_fluxs].flatten

      break unless next_fluxs.any?
    end

    new_fluxs
  end

  def self.get_fluxs
    {
      fluxs: Mushy::Flux.all
                        .select { |x| x.respond_to? :details }
                        .select(&:details)
                        .map do |flux|
                          details = flux.details

                          details[:documentation] = Mushy::Builder::Documentation.build_from details

                          details[:config][:incoming_split] = { type: 'text', shrink: true, description: 'Split an incoming event into multiple events by this key, an each event will be processed independently.', default: '' }
                          details[:config][:outgoing_split] = { type: 'text', shrink: true, description: 'Split an outgoing event into multiple events by this key.', default: '' }
                          details[:config][:merge] = { type: 'text', shrink: true, description: 'A comma-delimited list of fields from the event to carry through. Use * to merge all fields.', default: '' }
                          details[:config][:group] = { type: 'text', shrink: true, description: 'Group events by this key, with the value as the key. If a group key is provided like group_by|group_key, then multiple events with the results under group_key will be returned.', default: '' }
                          details[:config][:limit] = { type: 'integer', shrink: true, description: 'Limit the number of events to this number.', default: '' }
                          details[:config][:join] = { type: 'text', shrink: true, description: 'Join all of the events from this flux into one event, under this name.', default: '' }
                          details[:config][:sort] = { type: 'text', shrink: true, description: 'Sort by this key.', default: '' }
                          details[:config][:ignore] = { type: 'text', shrink: true, description: 'Ignore these keys.', value: '', default: '' }
                          details[:config][:model] = { type: 'keyvalue', shrink: true, description: 'Reshape the outgoing events.', value: {}, default: {} }

                          details[:config][:error_strategy] = {
                            description: 'Error strategy. (return to return an event with "exception" returning the error, or ignore to ignore the exception)',
                            type: 'select',
                            options: ['', 'return', 'ignore'],
                            value: '',
                            shrink: true
                          }

                          if flux.new.respond_to? :loop
                            details[:config][:run_strategy] = {
                              description: 'Run this using this strategy. (select "daemon" if this should be run in the background)',
                              type: 'select',
                              options: ['', 'inline', 'daemon'],
                              value: '',
                              shrink: true
                            }
                          end

                          details[:config]
                            .select { |_, v| v[:type] == 'keyvalue' }
                            .select { |_, v| v[:editors].nil? }
                            .each do |_, v|
                              v[:editors] = [
                                { id: 'new_key', target: 'key', field: { type: 'text', value: '', default: '' } },
                                { id: 'new_value', target: 'value', field: { type: 'text', value: '', default: '' } }
                              ]
                            end

                          details
                        end.sort_by { |x| x[:name] }
    }
  end
end
