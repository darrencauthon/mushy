require 'ferrum'

module Mushy

  class Browser < Step

    def process step, config
      browser = Ferrum::Browser.new

      (config[:cookies] || []).each do |cookie|
        brower.cookies.set nil, nil, cookie
      end

      browser.headers.add(config[:headers]) if config[:headers]

      browser.goto config[:url]

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