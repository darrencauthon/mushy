require 'nokogiri'

module Mushy
  
  class ParseHtml < Step

    def process event, config

      content = event[config[:path]]
      doc = Nokogiri::HTML content

      matches = {}
      config[:extract].keys.each do |key|
        extract = config[:extract][key]
        css, value = extract.split('|')
        value = value || './node()'
        matches[key] = doc.css(css).map { |x| x.xpath(value).to_s }
      end

      matches[matches.keys.first]
         .each_with_index
         .map { |_, i| i }
         .map do |i|
                matches.keys.reduce(SymbolizedHash.new( { } )) do |t, key|
                  t[key] = matches[key][i]
                  t[key] = t[key].strip if t[key]
                  t
                end
              end
    end

  end

end
