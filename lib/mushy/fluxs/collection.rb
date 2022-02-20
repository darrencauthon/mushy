module Mushy

  class Collection < Flux

    def self.details
      {
        name: 'Collection',
        description: 'Collects events.',
        fluxGroup: { name: 'Data', position: 0 },
        config: {
          id: {
                description: 'The path to the unique id in the body of the element.',
                type: 'text',
                value: '{{id}}',
              },
          collection_name: {
                             description: 'The name of the collection to interact with.',
                             type:        'text',
                             value:       'records',
                           },
          operation: {
                       description: 'Perform this operation.',
                       type:        'select',
                       options:     ['all', 'delete', 'upsert', 'update', 'insert'],
                       value:       'upsert',
                     },
        },
      }
    end

    def process event, config
      self.send(config[:operation].to_sym, event, config)
    end

    def get_the_id event, config
      config[:id]
    end

    def all event, config
      the_collection(config).values
    end

    def delete event, config
      the_collection(config).delete get_the_id(event, config)
      event[config[:operation_performed]] = 'deleted' if config[:operation_performed]
      event
    end

    def upsert event, config
      if the_collection(config)[get_the_id(event, config)]
        update event, config
      else
        insert event, config
      end
    end

    def update event, config
      item = the_collection(config)[get_the_id(event, config)]
      event.each { |k, v| item[k] = v } if item
      event[config[:operation_performed]] = (item ? 'updated' : 'not exist') if config[:operation_performed]
      event
    end

    def insert event, config
      the_collection(config)[get_the_id(event, config)] = event
      event[config[:operation_performed]] = 'inserted' if config[:operation_performed]
      event
    end

    def the_collection config
      Mushy::Collection.guard_the_flow self.flow
      the_collection_name = config[:collection_name]

      get_the_collection the_collection_name
    end

    def get_the_collection name
      found_collection = self.flow.collection_data[name]
      return found_collection if found_collection
      self.flow.collection_data[name] = SymbolizedHash.new
    end

    def self.guard_the_flow flow
      return if flow.respond_to?(:collection_data)

      flow.instance_eval { class << self; self end }.send(:attr_accessor, :collection_data)
      flow.collection_data = {}
    end

  end

end