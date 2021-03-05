require 'pony'

module Mushy
  
  class Smtp < Flux

    def self.details
      {
        name: 'Smtp',
        description: 'Send email through SMTP.',
        config: {
          to: {
                description: 'To whom the email should be sent.',
                type:        'text',
                value:       '',
              },
          subject: {
                     description: 'The subject of the email.',
                     type:        'text',
                     value:       '',
                   },
          body: {
                  description: 'The text body of the email.',
                  type:        'textarea',
                  value:       '',
                },
          html_body: {
                  description: 'The HTML body of the email.',
                  type:        'textarea',
                  value:       '',
                },
          address: {
                     description: 'The address of the SMTP server.',
                     type:        'text',
                     value:       'smtp.gmail.com',
                   },
          port: {
                  description: 'The SMTP server port.',
                  type:        'integer',
                  value:       '587',
                },
          username: {
                      description: 'The username.',
                      type:        'text',
                      value:       '',
                    },
          password: {
                      description: 'The password.',
                      type:        'text',
                      value:       '',
                    },
        },
      }
    end

    def process event, config
      options = adjust(cleanup({
          to: config[:to],
          subject: config[:subject],
          body: config[:body],
          html_body: config[:html_body],
          via_options: get_via_options_from(config)
      }))
      result = Pony.mail options
      options.tap { |x| x.delete(:via_options) }
      options
    end

    def adjust options
      options.tap { |x| x[:via] = 'smtp' }
    end

    def cleanup options
      options.tap do |hash|
        hash.delete_if { |_, v| v.to_s == '' }
      end
    end

    def get_via_options_from config
      {
        address:  config[:address],
        port:     config[:port].to_s,
        user_name: config[:username],
        password: config[:password],
        enable_starttls_auto: true,
        authentication: :plain,
        domain: 'gmail.com',
      }
    end

  end

end