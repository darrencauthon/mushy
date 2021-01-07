module Mushy

  class Crud < Step

    attr_accessor :collection

    def initialize
      self.collection = {}
      super
    end

    def process event, config
      collection = config[:collection]
      id = event[config[:id]]

      if self.collection[id]
        event.each { |k, v| self.collection[id][k] = v }
      else
        self.collection[id] = event
      end

      nil
    end

  end

end