# frozen_string_literal: true

require 'faraday'

#
# A DELETE request.
#
class Mushy::Delete < Mushy::HttpOperation
  def self.details
    super.merge({
                  examples: {
                    'Successful Call' => {
                      description: 'This will send a DELETE to an API endpoint.',
                      config: { url: 'http://localhost:3000/api/v1/db/data/v1/people/1' },
                      result: {
                        status: 200,
                        url: 'http://localhost:3000/api/v1/db/data/v1/people/1',
                        time: 0.11498799989931285,
                        reason_phrase: 'OK',
                        headers: {
                          'content-type' => 'application/json; charset=utf-8',
                          'content-length' => '1'
                        },
                        body: '1'
                      }
                    }
                  }
                })
  end
end
