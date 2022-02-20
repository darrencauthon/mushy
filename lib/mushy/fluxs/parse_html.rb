require 'nokogiri'

module Mushy
  
  class ParseHtml < Flux

    def self.details
      {
        name: 'ParseHtml',
        title: 'Parse HTML',
        fluxGroup: { name: 'Web' },
        description: 'Extract data from HTML.',
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
                   }
        },
        examples: {
          "Example 1" => {
                           description: 'Pulling all links out of HTML.',
                           input: {
                                    html: '<a href="one">First</a><a href="two">Second</a>'
                                  },
                           config: {
                                     path: 'html',
                                     extract: {
                                       url: "a|@href",
                                       name: "a"
                                     },
                                   },
                           result: [
                              { url: 'one', name: 'First' },
                              { url: 'two', name: 'Second' }
                            ]
                         },
          "Example 2" => {
                           description: 'Pulling the contents of a single div.',
                           input: {
                                      html: "<div class=\"main\" data-this=\"you\">HEY</a>"
                                  },
                           config: {
                                     path: 'html',
                                     extract: {
                                                content: "div.main",
                                                class: "div|@class",
                                                "data-this" => "div|@data-this",
                                              },
                                   },
                           result: { content: 'HEY', class: 'main', "data-this" => "you" },
                         },
          }
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
