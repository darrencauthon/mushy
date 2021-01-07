module Mushy

  class Crud < Step

    attr_accessor :collections

    def initialize
      self.collections = {}
      super
    end

    def process event, config
      collection = config[:collection]
      id = event[config[:id]]
      self.collections[collection] = { id => event }
      nil
    end

  end

end