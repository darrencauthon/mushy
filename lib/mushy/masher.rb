module Mushy

  class Masher

    def mash value, data

      return if value.is_a? String
               Liquid::Template.parse(value).render SymbolizedHash.new(data)
             elsif value.is_a? Hash
               value.each { |k, v| value[k] = mash v, data }
             elsif value.is_a? Array
               value.map { |v| mash v, data }
             else
               value
             end

    end

  end

end