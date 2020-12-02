module Mushy

  class Masher

    attr_accessor :mash_methods

    def initialize
      self.mash_methods = 
        {
          String => ->(x, d) { Liquid::Template.parse(x).render SymbolizedHash.new(d) },
          Hash   => ->(x, d) { x.each { |k, v| x[k] = mash v, d } },
          Array  => ->(x, d) { x.map { |x| mash x, d } }
        }
    end

    def mash value, data
      method_for(value).call value, data
    end

    def method_for value
      mash_methods
        .select { |k, _| value.is_a? k }
        .map    { |_, v| v }
        .first || ->(x, _) { x }
    end

  end

end