require 'nokogiri'

module Mushy
  
  class ParseHtml < Step

    def self.details
      {
        name: 'ParseHtml',
        description: 'Parses HTML.',
        config: {
          path: {
                  description: 'The path to the HTML in the incoming event.',
                  type:        'text',
                  value:       'body',
                },
          extract: {
                     description: 'The form of the event that is meant to be pulled from this event.',
                     type: 'keyvalue',
                     value: { url: 'a|@href' },
                     editors: [
                                 { id: 'new_key', target: 'key', field: { type: 'text', value: '', default: '' } },
                                 { id: 'new_value', target: 'value', field: { type: 'text', value: '', default: '' } }
                              ],
                   }
        },
      }
    end

    def process event, config

      doc = Nokogiri::HTML event[config[:path]]

      matches = config[:extract].keys.reduce( { } ) do |matches, key|
        css, value = config[:extract][key].split('|')
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
