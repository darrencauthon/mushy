require 'nokogiri'

module Mushy
  
  class ParseHtml < Step

    def process event, config

      doc = Nokogiri::HTML event[config[:path]]

      matches = config[:extract].keys.reduce( { } ) do |matches, key|
        extract = config[:extract][key]
        css, value = extract.split('|')
        value = value || './node()'
        matches[key] = doc.css(css).map { |x| x.xpath(value).to_s }
        matches
      end

      matches[matches.keys.first]
         .each_with_index
         .map { |_, i| i }
         .map do |i|
                matches.keys.reduce(SymbolizedHash.new( { } )) do |record, key|
                  record[key] = matches[key][i]
                  record[key] = record[key].strip if record[key]
                  record
                end
              end
    end

  end

end
