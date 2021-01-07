module Mushy

  class Crud < Step

    attr_accessor :collection

    def initialize
      self.collection = {}
      super
    end

    def process event, config
      id = event[config[:id]]

      if config[:operation] == 'delete'
        self.collection.delete id
      else
        if self.collection[id]
          event.each { |k, v| self.collection[id][k] = v }
        else
          self.collection[id] = event
        end
      end

      nil
    end

  end

end