module Mushy

  class Masher

    attr_accessor :mash_methods

    def initialize
      self.mash_methods = 
        {
          String => ->(x, d) do
                               x.match('{{\s?(\w*)\s?}}') do |m|
                                 if (m.captures.count == 1)
                                   match_on_key = d.keys.select { |x| x.to_s == m.captures[0].to_s }.first
                                   value = dig match_on_key.to_s, d
                                   return value unless value.is_a?(String) || value.is_a?(Numeric)
                                 end
                               end
                               Liquid::Template.parse(x).render SymbolizedHash.new(d)
                             end,
          Hash   => ->(x, d) do
                               h = SymbolizedHash.new(x)
                               h.each { |k, v| h[k] = mash v, d }
                               h
                             end,
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

    def dig key, data
      return nil unless key

      segments = key.split '.'

      segments.each do |segment|
        data = data.is_a?(Hash) ? (data[segment] || data[segment.to_sym]) : (data ? data.send(segment.to_sym) : nil)
      end

      data
    end

  end

end