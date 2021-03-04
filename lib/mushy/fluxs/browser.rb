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
                      shrink:      true,
                      value:       'true',
                    },
          timeout: {
                     description: 'The default timeout (in seconds) before closing the browser. Default is 5 seconds.',
                     type:        'integer',
                     shrink:      true,
                     value:       '',
                   },
          execute: {
                     description: 'Javascript to run after the page is loaded.',
                     type:        'textarea',
                     shrink:      true,
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
                   },
          carry_cookies_from: {
                     description: 'Carry the cookies from this path in the event. Defaults to "cookies".',
                     type:        'text',
                     shrink:      true,
                     value:       '',
                   },
          headers: {
                     description: 'Headers for the web request. These can be received from a previous browser event with {{headers}}, or can be typed manually.',
                     type:        'keyvalue',
                     shrink:      true,
                     value:       {},
                   },
          carry_headers_from: {
                     description: 'Carry the headers from this path in the event. Defaults to "headers".',
                     type:        'text',
                     shrink:      true,
                     value:       '',
                   },
          wait_before_closing: {
                                 description: 'Wait this many seconds before closing the browser.',
                                 type:        'integer',
                                 shrink:      true,
                                 value:       '',
                               },
        },
      }
    end

    def process event, config

      timeout = config[:timeout] ? config[:timeout].to_i : 5

      browser = Ferrum::Browser.new(
        headless: (config[:headless].to_s != 'false'),
        timeout: timeout)

      get_the_cookies_from(event, config).each { |c| browser.cookies.set(c) }

      browser.headers.add get_the_headers_from(event, config)

      browser.goto config[:url]

      browser.execute(config[:execute]) if config[:execute]

      sleep(config[:wait_before_closing].to_i) if config[:wait_before_closing] && config[:wait_before_closing].to_i > 0

      result = {
        url: browser.url,
        status: browser.network.status,
        title: browser.frames[0].title,
        cookies: browser.cookies.all.map { |k, v| v.instance_variable_get('@attributes') },
        headers: browser.headers.get,
        body: browser.body
      }

      result = special_browser_action( { browser: browser, result: result, config: config } )

      browser.quit

      result
    end

    def special_browser_action _
      result
    end

    def get_the_cookies_from event, config
      carry_cookies_from = config[:carry_cookies_from].to_s == '' ? 'cookies' : config[:carry_cookies_from]
      cookies = event[carry_cookies_from.to_sym]
      cookies = [] unless cookies.is_a?(Array)
      config[:cookies] = [] unless config[:cookies].is_a?(Array)
      config[:cookies].each { |x| cookies << x }
      cookies
    end

    def get_the_headers_from event, config
      carry_headers_from = config[:carry_headers_from].to_s == '' ? 'headers' : config[:carry_headers_from]
      headers = event[carry_headers_from.to_sym]
      headers = {} unless headers.is_a?(Hash)
      config[:headers] = {} unless config[:headers].is_a?(Hash)
      config[:headers].each { |k, v| headers[k] = v }
      headers
    end

  end

end