require 'ferrum'

module Mushy

  class Browser < Step

    def process step, config
      browser = Ferrum::Browser.new(headless: false)
      browser.goto config[:url]

      {
        url: browser.url,
      }
    end

  end

end