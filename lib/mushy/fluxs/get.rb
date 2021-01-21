require 'faraday'

module Mushy
  
  class Get < Flux

    def process event, config

      faraday = Faraday.new do |connection|
        connection.adapter Faraday.default_adapter
      end

      headers = config[:headers] || {}
      data = {}
      url = config[:url]

      response = faraday.get config[:url], data, headers

      {
        status: response.status,
        url: url,
        reason_phrase: response.reason_phrase,
        headers: response.headers,
        body: response.body,
      }
    end

  end

end