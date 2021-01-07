module Mushy

  class Crud < Step

    attr_accessor :collection

    def initialize
      self.collection = {}
      super
    end

    def process event, config
      id = event[config[:id]]

      if config[:operation] == 'all'
        return self.collection.values
      elsif config[:operation] == 'delete'
        self.collection.delete id
        event[config[:operation_performed]] = 'deleted' if config[:operation_performed]
      else
        if self.collection[id]
          event.each { |k, v| self.collection[id][k] = v }
          event[config[:operation_performed]] = 'updated' if config[:operation_performed]
        else
          self.collection[id] = event
          event[config[:operation_performed]] = 'inserted' if config[:operation_performed]
        end
      end

      event
    end

  end

end