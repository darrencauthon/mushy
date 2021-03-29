module Mushy

  class Special < Flux

    attr_accessor :collection

    def self.details
      {
        name: 'Special',
        description: 'Collects events.',
        config: {
          id: {
                description: 'The path to the unique id in the body of the element.',
                type: 'id',
                value: { url: 'a|@href' },
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

    def initialize
      self.collection = {}
      super
    end

    def process event, config
      self.send(config[:operation].to_sym, event, config)
    end

    def get_the_id event, config
      event[config[:id]]
    end

    def all event, config
      self.collection[config[:collection_name]].values
    end

    #def delete event, config
      #self.collection.delete get_the_id(event, config)
      #event[config[:operation_performed]] = 'deleted' if config[:operation_performed]
      #event
    #end

    #def upsert event, config
      #if self.collection[get_the_id(event, config)]
        #update event, config
      #else
        #insert event, config
      #end
    #end

    #def update event, config
      #item = self.collection[get_the_id(event, config)]
      #event.each { |k, v| item[k] = v } if item
      #event[config[:operation_performed]] = (item ? 'updated' : 'not exist') if config[:operation_performed]
      #event
    #end

    #def insert event, config
      #self.collection[get_the_id(event, config)] = event
      #event[config[:operation_performed]] = 'inserted' if config[:operation_performed]
      #event
    #end

  end

end