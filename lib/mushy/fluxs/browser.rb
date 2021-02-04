require 'ferrum'

module Mushy

  class Browser < Flux

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
                      type:        'boolean',
                      value:       'true',
                    },
          execute: {
                     description: 'Javascript to run after the page is loaded.',
                     type:        'textarea',
                     value:       '',
                   },
          cookies: {
                     description: 'Cookies for the web request. These can be received from a previous browser event with {{cookies}}, or can be typed manually.',
                     type:        'editgrid',
                     shrink:      true,
                     value:       [],
                     editors: [
                                 { id: 'name', target: 'name', field: { type: 'text', value: '', default: '' } },
                                 { id: 'value', target: 'value', field: { type: 'text', value: '', default: '' } },
                                 { id: 'domain', target: 'domain', field: { type: 'text', value: '', default: '' } },
                                 { id: 'path', target: 'path', field: { type: 'text', value: '', default: '' } },
                                 { id: 'expires', target: 'expires', field: { type: 'text', value: '', default: '' } },
                                 { id: 'size', target: 'size', field: { type: 'integer', value: 0, default: 0 } },
                                 { id: 'httpOnly', target: 'httpOnly', field: { type: 'boolean', value: false, default: false } },
                                 { id: 'secure', target: 'secure', field: { type: 'boolean', value: true, default: true } },
                                 { id: 'sameSite', target: 'sameSite', field: { type: 'text', value: 'None', default: 'None' } },
                                 { id: 'priority', target: 'priority', field: { type: 'text', value: 'Medium', default: 'Medium' } },
                              ],
                     #{"name":"1P_JAR","value":"2021-01-21-13","domain":".google.com","path":"/","expires":1613828458.870408,"size":19,"httpOnly":false,"secure":true,"session":false,"sameSite":"None","priority":"Medium"
                   },
          carry_cookies_from: {
                     description: 'Carry the cookies from this path in the event.',
                     type:        'text',
                     value:       'cookies',
                   },
          headers: {
                     description: 'Headers for the web request. These can be received from a previous browser event with {{headers}}, or can be typed manually.',
                     type:        'keyvalue',
                     value:       {},
                   },
          carry_headers_from: {
                     description: 'Carry the headers from this path in the event.',
                     type:        'text',
                     value:       'headers',
                   },
          wait_before_closing: {
                                 description: 'Wait this many seconds before closing the browser.',
                                 type:        'integer',
                                 value:       '',
                               },
        },
      }
    end

    def process event, config

      browser = Ferrum::Browser.new(headless: (config[:headless].to_s != 'false'))

      get_the_cookies_from(event, config).each { |c| browser.cookies.set(c) }

      browser.headers.add get_the_headers_from(event, config)

      browser.goto config[:url]

      browser.execute(config[:execute]) if config[:execute]

      result = {
        url: browser.url,
        cookies: browser.cookies.all.map { |k, v| v.instance_variable_get('@attributes') },
        headers: browser.headers.get,
        body: browser.body
      }

      sleep(config[:wait_before_closing].to_i) if config[:wait_before_closing] && config[:wait_before_closing].to_i > 0

      browser.quit

      result
    end

    def get_the_cookies_from event, config
      cookies = (event[config[:carry_cookies_from].to_sym])
      cookies = [] unless cookies.is_a?(Array)
      config[:cookies] = [] unless config[:cookies].is_a?(Array)
      config[:cookies].each { |x| cookies << x }
      cookies
    end

    def get_the_headers_from event, config
      headers = (event[config[:carry_headers_from].to_sym])
      headers = {} unless headers.is_a?(Hash)
      config[:headers] = {} unless config[:headers].is_a?(Hash)
      config[:headers].each { |k, v| headers[k] = v }
      headers
    end

  end

end