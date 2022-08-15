# frozen_string_literal: true

require 'faraday'

#
# A POST request.
#
class Mushy::Post < Mushy::Flux
  def self.details
    {
      name: 'Post',
      title: 'Make a POST call',
      fluxGroup: { name: 'Web' },
      description: 'Makes a POST call to a URL',
      config: {
        url: {
          description: 'The URL to visit.',
          type: 'text',
          value: 'https://www.google.com'
        },
        headers: {
          description: 'Headers for the web request.',
          type: 'keyvalue',
          shrink: true,
          value: {}
        },
        params: {
          description: 'Parameters for the URL.',
          type: 'keyvalue',
          shrink: true,
          value: {}
        },
        body: {
          description: 'The body of the request.',
          type: 'text',
          shrink: true,
          value: ''
        },
      },
      examples: {
        'Successful Call' => {
          description: 'This will send a POST to https://www.google.com.',
          config: { url: 'https://www.google.com' },
          result: {
            status: 400,
            url: 'https://www.google.com',
            time: 0.12829399993643165,
            reason_phrase: 'OK',
            headers: {
              'access-control-allow-origin': '*',
              'content-type': 'application/json; charset=utf-8',
              'content-length': '193',
              'keep-alive': 'timeout=5'
            },
            body: '{}'
          }
        }
      }
    }
  end

  def process(_event, config) # rubocop:disable Metrics/MethodLength
    args = {
      params: config[:params],
      headers: config[:headers]
    }

    faraday = Faraday.new(**args) do |connection|
      connection.adapter Faraday.default_adapter
    end

    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    response = faraday.post(config[:url]) do |request|
      request.body = config[:body] if config[:body].to_s != ''
    end

    time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

    url = response.instance_variable_get(:@env).url.to_s

    {
      status: response.status,
      url: url,
      time: time,
      reason_phrase: response.reason_phrase,
      headers: response.headers,
      body: response.body
    }
  end
end
