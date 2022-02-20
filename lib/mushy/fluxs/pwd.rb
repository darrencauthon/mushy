module Mushy

  class Pwd < Bash

    def self.details
      {
        name: 'Pwd',
        title: 'Get the working directory',
        description: 'Run the "pwd" command.',
        fluxGroup: { name: 'Environment' },
        config: Mushy::Bash.details[:config].tap { |c| c.delete :command },
      }.tap do |c|
        c[:examples] = {
          "Example" => {
                         description: 'This will run the pwd command and return the directory information.',
                         result: {
                                   pwd: {
                                     inode: "403091",
                                     hard_links: 5,
                                     owner: "pi",
                                     group: "pi",
                                     size: 4095,
                                     date: {
                                       year: 2020,
                                       month: 9,
                                       day: 5,
                                       hour: 10,
                                       minute: 43,
                                       second: 36,
                                       nanosecond: 325720074,
                                       utc_offset: -18001,
                                       weekday: 2,
                                       day_of_month: 5,
                                       day_of_year: 278,
                                       string: "2020-10-06 11:44:37 -0500",
                                       epoch_integer: 1633538676,
                                       epoch_float: 1633538676.32572,
                                       seconds_ago: 17558.38995246
                                     },
                                     name: "mushy",
                                     type: "d",
                                     owner_permission: "rwx",
                                     group_permission: "r-x",
                                     other_permission: "r-x",
                                     directory: "/home/pi/Desktop",
                                     path: "/home/pi/Desktop/mushy"
                                 }
                                 }
                       }
                       }
      end
    end

    def process event, config

      config[:command] = 'pwd'

      result = super event, config

      return result unless result[:success]

      pwd = result[:text].to_s.strip

      {
        pwd: Mushy::Ls.new.process({}, { path: pwd, directory_only: true })[0]
      }

    end

  end

end