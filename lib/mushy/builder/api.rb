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

      def self.get_flow file
        puts "trying to get: #{file}"
        file = "#{file}.json" unless file.downcase.end_with?('.json')
        JSON.parse File.open(file).read
      rescue
        { fluxs: [] }
      end

      def self.get_fluxs
        {
          fluxs: Mushy::Flux.all.select { |x| x.respond_to? :details }.map do |flux|
                         details = flux.details
                         details[:config][:incoming_split] = { type: 'text', description: 'Split an incoming event into multiple events by this key, an each event will be processed independently.', default: '' }
                         details[:config][:outgoing_split] = { type: 'text', description: 'Split an outgoing event into multiple events by this key.', default: '' }
                         details[:config][:merge] = { type: 'text', description: 'A comma-delimited list of fields from the event to carry through. Use * to merge all fields.', default: '' }
                         details[:config][:group] = { type: 'text', description: 'Group events by a field, which is stored in a key. The format is group_by|group_key.', default: '' }
                         details[:config][:limit] = { type: 'integer', description: 'Limit the number of events to this number.', default: '' }
                         details[:config][:join] = { type: 'text', description: 'Join all of the events from this flux into one event, under this name.', default: '' }
                         details[:config][:sort] = { type: 'text', description: 'Sort by this key.', default: '' }
                         details[:config][:model] = { type: 'keyvalue', description: 'Reshape the outgoing events.', value: {}, default: {} }

                         details[:config]
                                .select { |_, v| v[:type] == 'keyvalue' }
                                .select { |_, v| v[:editors].nil? }
                                .each   do |_, v|
                                          v[:editors] = [
                                                    { id: 'new_key', target: 'key', field: { type: 'text', value: '', default: '', shrink: true } },
                                                    { id: 'new_value', target: 'value', field: { type: 'text', value: '', default: '', shrink: true  } }
                                                  ]
                                  end

                         details
                 end
        }
      end

    end

  end

end