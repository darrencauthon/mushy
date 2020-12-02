module Mushy
  class Masher
    def mash value, data
      return Liquid::Template.parse(value).render SymbolizedHash.new(data) if value.is_a? String
      value.each { |k, v| value[k] = mash v, data }
      return value
    end
  end
end