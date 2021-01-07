module Mushy

  class Crud < Step

    attr_accessor :collection

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
      self.collection.values
    end

    def delete event, config
      self.collection.delete get_the_id(event, config)
      event[config[:operation_performed]] = 'deleted' if config[:operation_performed]
      event
    end

    def upsert event, config
      if self.collection[get_the_id(event, config)]
        update event, config
      else
        insert event, config
      end
    end

    def update event, config
      event.each { |k, v| self.collection[get_the_id(event, config)][k] = v }
      event[config[:operation_performed]] = 'updated' if config[:operation_performed]
      event
    end

    def insert event, config
      self.collection[get_the_id(event, config)] = event
      event[config[:operation_performed]] = 'inserted' if config[:operation_performed]
      event
    end

  end

end