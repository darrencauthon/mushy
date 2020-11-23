module Mushy
  class Masher
    def mash one, two
      Liquid::Template.parse(one).render SymbolizedHash.new(two)
    end
  end
end