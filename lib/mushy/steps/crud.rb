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
      self.collection[id] = event
      nil
    end

  end

end