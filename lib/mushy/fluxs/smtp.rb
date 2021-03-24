require 'pony'

module Mushy

  class EmailBase < Flux

    def process event, config
      options = adjust(cleanup({
          from: config[:from],
          to: config[:to],
          subject: config[:subject],
          body: config[:body],
          html_body: config[:html_body],
          via_options: get_via_options_from(config)
      }))

      if (config[:attachment_file].to_s != '')
        options[:attachments] = { config[:attachment_file].split("\/")[-1] => File.read(config[:attachment_file]) }
      end

      result = Pony.mail options
      options.tap { |x| x.delete(:via_options) }
    end

    def adjust options
    end

    def cleanup options
      options.tap do |hash|
        hash.delete_if { |_, v| v.to_s == '' }
      end
    end

    def get_via_options_from config
      {
        address:              config[:address],
        port:                 config[:port].to_s,
        user_name:            config[:username],
        password:             config[:password],
        domain:               config[:domain],
        authentication:       :plain,
        enable_starttls_auto: true,
      }
    end
  end
  
  class Smtp < EmailBase

    def self.details
      {
        name: 'Smtp',
        description: 'Send email through SMTP.',
        config: {
          from: {
                  description: 'From whom the email will be sent.',
                  type:        'text',
                  shrink:      true,
                  value:       '',
                },
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
          attachment_file: {
                             description: 'The full path of a file to attach.',
                             type:        'text',
                             shrink:      true,
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
          domain: {
                    description: 'The email domain.',
                    type:        'text',
                    value:       'gmail.com',
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

    def adjust options
      options.tap { |x| x[:via] = 'smtp' }
    end

  end

end