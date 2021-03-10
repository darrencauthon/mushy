module Mushy

  module Builder

    module Api

      def self.run data

        data = SymbolizedHash.new JSON.parse(data)

        event = SymbolizedHash.new JSON.parse(data[:setup][:event].to_json)

        config = SymbolizedHash.new data[:config]

        flux = Mushy::Flow.build_flux( { type: data[:setup][:flux], config: config } )

        result = flux.execute event

        [result].flatten
      end

      def self.save file, data

        file = "#{file}.json" unless file.downcase.end_with?('.json')

        data = SymbolizedHash.new JSON.parse(data)
        Mushy::WriteFile.new.process( {}, { name: file, data: data.to_json })

      end

      def self.start file, event
        file = "#{file}.json" unless file.downcase.end_with?('.json')
        flow = File.open(file).read
        flow = Mushy::Flow.parse flow

        service_fluxes = flow.fluxs.select { |x| x.kind_of?(Mushy::ServiceFlux) }

        puts service_fluxes.inspect
        if service_fluxes.any?
          service_flux = service_fluxes.first
          my_call = ->() do
            service_flux.start
            Mushy::Runner.new.start event, service_flux, flow
          end
          loop &my_call
        end

        cli_flux = flow.fluxs.select { |x| x.kind_of?(Mushy::Cli) }.first

        puts cli_flux.kind_of?(Mushy::Cli).inspect
        throw 'hey'

        Mushy::Runner.new.start event, cli_flux, flow
      end

      def self.get_flow file
        puts "trying to get: #{file}"
        file = "#{file}.json" unless file.downcase.end_with?('.json')
        data = JSON.parse File.open(file).read
        data['fluxs']
          .reject { |x| x['parents'] }
          .each   { |x| x['parents'] = [x['parent']].select { |y| y } }
        data['fluxs']
          .select { |x| x['parent'] }
          .each   { |x| x.delete 'parent' }
        data['fluxs']
          .select { |x| x['parents'] }
          .each   { |x| x['parents'] = x['parents'].select { |y| y } }
        data
      rescue
        { fluxs: [] }
      end

      def self.get_fluxs
        {
          fluxs: Mushy::Flux.all.select { |x| x.respond_to? :details }.map do |flux|
                         details = flux.details
                         details[:config][:incoming_split] = { type: 'text', shrink: true, description: 'Split an incoming event into multiple events by this key, an each event will be processed independently.', default: '' }
                         details[:config][:outgoing_split] = { type: 'text', shrink: true, description: 'Split an outgoing event into multiple events by this key.', default: '' }
                         details[:config][:merge] = { type: 'text', shrink: true, description: 'A comma-delimited list of fields from the event to carry through. Use * to merge all fields.', default: '' }
                         details[:config][:group] = { type: 'text', shrink: true, description: 'Group events by a field, which is stored in a key. The format is group_by|group_key.', default: '' }
                         details[:config][:limit] = { type: 'integer', shrink: true, description: 'Limit the number of events to this number.', default: '' }
                         details[:config][:join] = { type: 'text', shrink: true, description: 'Join all of the events from this flux into one event, under this name.', default: '' }
                         details[:config][:sort] = { type: 'text', shrink: true, description: 'Sort by this key.', default: '' }
                         details[:config][:model] = { type: 'keyvalue', shrink: true, description: 'Reshape the outgoing events.', value: {}, default: {} }

                         details[:config]
                                .select { |_, v| v[:type] == 'keyvalue' }
                                .select { |_, v| v[:editors].nil? }
                                .each   do |_, v|
                                          v[:editors] = [
                                                    { id: 'new_key', target: 'key', field: { type: 'text', value: '', default: '' } },
                                                    { id: 'new_value', target: 'value', field: { type: 'text', value: '', default: '' } }
                                                  ]
                                  end

                         details
                 end
        }
      end

    end

  end

end