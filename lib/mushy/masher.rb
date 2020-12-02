module Mushy
  class Masher
    def mash value, data
      return Liquid::Template.parse(value).render SymbolizedHash.new(data) if value.is_a? String

      if value.is_a? Hash
        value = value.each { |k, v| value[k] = mash v, data }
      elsif value.is_a? Array
        value = value.map { |v| mash v, data }
      end

      return value
    end
  end
end