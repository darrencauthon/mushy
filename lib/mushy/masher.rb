module Mushy
  class Masher
    def mash value, data

      if value.is_a? String
        return Liquid::Template.parse(value).render SymbolizedHash.new(data)
      elsif value.is_a? Hash
        return value.each { |k, v| value[k] = mash v, data }
      elsif value.is_a? Array
        return value.map { |v| mash v, data }
      end

      return value
    end
  end
end