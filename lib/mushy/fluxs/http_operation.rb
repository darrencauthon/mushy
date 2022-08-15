# frozen_string_literal: true

require 'faraday'

#
# A HTTP Operation request.
#
class Mushy::HttpOperation < Mushy::Flux
  def self.operation
    name.split('::').last.downcase
  end

  def operation
    self.class.operation
  end

  def self.details
    {
      name: operation.capitalize,
      title: "Make a #{operation.upcase} call",
      fluxGroup: { name: 'Web' },
      description: "Makes a #{operation} call to a URL",
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

    response = faraday.send(operation.to_sym, config[:url]) do |request|
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
