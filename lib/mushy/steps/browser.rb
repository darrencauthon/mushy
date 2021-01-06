require 'ferrum'

module Mushy

  class Browser < Step

    def process step, config

      config[:cookies] = [] unless config[:cookies].is_a?(Array)
      config[:headers] = {} unless config[:headers].is_a?(Hash)

      browser = Ferrum::Browser.new(headless: false)

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