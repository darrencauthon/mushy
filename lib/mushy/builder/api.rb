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

      def self.get_fluxs
        {
          fluxs: Mushy::Flux.all.select { |x| x.respond_to? :details }.map do |flux|
                         details = flux.details
                         details[:config][:incoming_split] = { type: 'text', description: 'Split an incoming event into multiple events by this key, an each event will be processed independently.' }
                         details[:config][:outgoing_split] = { type: 'text', description: 'Split an outgoing event into multiple events by this key.' }
                         details[:config][:merge] = { type: 'text', description: 'A comma-delimited list of fields from the event to carry through. Use * to merge all fields.' }
                         details[:config][:group] = { type: 'text', description: 'Group events by a field, which is stored in a key. The format is group_by|group_key.' }
                         details[:config][:limit] = { type: 'integer', description: 'Limit the number of events to this number.' }
                         details[:config][:join] = { type: 'text', description: 'Join all of the events from this flux into one event, under this name.' }
                         details[:config][:sort] = { type: 'text', description: 'Sort by this key.' }
                         details[:config][:model] = { type: 'keyvalue', description: 'Reshape the outgoing events.', value: {} }

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