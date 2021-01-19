require 'ferrum'

module Mushy

  class Browser < Step

    def self.details
      {
        name: 'Browser',
        description: 'Visit a page in a browser.',
        config: {
          url: {
                 description: 'The URL to visit.',
                 type:        'text',
                 value:       'https://www.google.com',
               },
          headless: {
                      description: 'Run this browser headless.',
                      type:        'select',
                      value:       'true',
                      options:     ['true', 'false'],
                    },
          execute: {
                     description: 'Javascript to run after the page is loaded.',
                     type:        'textarea',
                     value:       '',
                   },
          cookies: {
                     description: 'Cookies for the web request. These can be received from a previous browser event with {{cookies}}, or can be typed manually.',
                     type:        'json',
                     value:       '{{cookies}}',
                   },
          headers: {
                     description: 'Headers for the web request. These can be received from a previous browser event with {{headers}}, or can be typed manually.',
                     type:        'json',
                     value:       '{{headers}}',
                   },
        },
      }
    end

    def process event, config

      config[:cookies] = [] unless config[:cookies].is_a?(Array)
      config[:headers] = {} unless config[:headers].is_a?(Hash)

      browser = Ferrum::Browser.new(headless: (config[:headless].to_s != 'false'))

      config[:cookies].each { |c| browser.cookies.set(c) }

      browser.headers.add config[:headers]

      browser.goto config[:url]

      browser.execute(config[:execute]) if config[:execute]

      result = {
        url: browser.url,
        cookies: browser.cookies.all.map { |k, v| v.instance_variable_get('@attributes') },
        headers: browser.headers.get,
        body: browser.body
      }

      browser.quit

      result
    end

  end

end