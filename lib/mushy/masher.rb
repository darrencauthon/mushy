module Mushy
  class Masher
    def mash value, data
      Liquid::Template.parse(value).render SymbolizedHash.new(data)
    end
  end
end