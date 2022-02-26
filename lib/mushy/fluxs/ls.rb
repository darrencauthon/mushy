module Mushy

  class Ls < Bash

    def self.the_ls_command
      @the_ls_command ||= find_the_right_ls_command_to_use
    end

    def self.find_the_right_ls_command_to_use
      commands = [
        'ls', # the normal method used to pull file information
        'gls' # BSD users don't get the version of ls this needs,
              # so we might need to use gls after the user runs (brew install coreutils)
      ]

      the_command_to_use = nil
      while the_command_to_use.nil? && (command = commands.shift) # keep trying till we find one that works
        the_command_to_use = command if Mushy::Bash.new.process({}, { command: "#{command} --full-time" })[:success]
      end
      the_command_to_use || -1
    end

    def self.details
      {
        name: 'Ls',
        title: 'List Files',
        description: 'Run the "ls" command.',
        fluxGroup: { name: 'Files' },
        config: Mushy::Bash.details[:config].tap { |c| c.delete :command },
      }.tap do |c|
        c[:config][:recursive] = {
                                   description: 'Pull files recursively.',
                                   type:        'boolean',
                                   shrink:      true,
                                   value:       '',
                                 }
        c[:config][:path] = {
                                description: 'Path, used to search for specific files.',
                                type:        'text',
                                shrink:      true,
                                value:       '',
                              }
      end.tap do |c|
        c[:examples] = {
          "Run In A Directory" => {
                         description: 'This will run the ls command in the specified directory.',
                         config: {
                           directory: '/home/pi/Desktop/mushy'
                         },
                         result: [{
                                   inode: "416921",
                                   hard_links: 1,
                                   owner: "pi",
                                   group: "pi",
                                   size: 1270,
                                   date: {
                                     year: 2021,
                                     month: 10,
                                     day: 1,
                                     hour: 10,
                                     minute: 43,
                                     second: 35,
                                     nanosecond: 664409766,
                                     utc_offset: -18000,
                                     weekday: 5,
                                     day_of_month: 1,
                                     day_of_year: 274,
                                     string: "2021-10-01 10:43:35 -0500",
                                     epoch_integer: 1633103015,
                                     epoch_float: 1633103015.6644099,
                                     seconds_ago: 454725.436212074
                                   },
                                   name: "mushy.gemspec",
                                   type: "-",
                                   owner_permission: "rw-",
                                   group_permission: "r--",
                                   other_permission: "r--",
                                   directory: "/home/pi/Desktop/mushy",
                                   path: "/home/pi/Desktop/mushy/mushy.gemspec"
                                  },
                                  {
                                    inode: "403479",
                                    hard_links: 3,
                                    owner: "pi",
                                    group: "pi",
                                    size: 4096,
                                    date: {
                                      year: 2021,
                                      month: 3,
                                      day: 18,
                                      hour: 8,
                                      minute: 58,
                                      second: 51,
                                      nanosecond: 149096220,
                                      utc_offset: -18000,
                                      weekday: 4,
                                      day_of_month: 18,
                                      day_of_year: 77,
                                      string: "2021-03-18 08:58:51 -0500",
                                      epoch_integer: 1616075931,
                                      epoch_float: 1616075931.1490963,
                                      seconds_ago: 17482042.0544623
                                    },
                                    name: "test",
                                    type: "d",
                                    owner_permission: "rwx",
                                    group_permission: "r-x",
                                    other_permission: "r-x",
                                    directory: "test"
                                  }
                                ]
                       },
          "Run For a Specific File" => {
                         description: 'This will run the ls command in the specified directory.',
                         config: {
                           path: 'mushy.gemspec'
                         },
                         result: {
                                   inode: "416921",
                                   hard_links: 1,
                                   owner: "pi",
                                   group: "pi",
                                   size: 1270,
                                   date: {
                                     year: 2021,
                                     month: 10,
                                     day: 1,
                                     hour: 10,
                                     minute: 43,
                                     second: 35,
                                     nanosecond: 664409766,
                                     utc_offset: -18000,
                                     weekday: 5,
                                     day_of_month: 1,
                                     day_of_year: 274,
                                     string: "2021-10-01 10:43:35 -0500",
                                     epoch_integer: 1633103015,
                                     epoch_float: 1633103015.6644099,
                                     seconds_ago: 454725.436212074
                                   },
                                   name: "mushy.gemspec",
                                   type: "-",
                                   owner_permission: "rw-",
                                   group_permission: "r--",
                                   other_permission: "r--",
                                   directory: "/home/pi/Desktop/mushy",
                                   path: "/home/pi/Desktop/mushy/mushy.gemspec"
                                  }
                       }
                       }
      end
    end

    def process event, config
      raise 'ls is not available' if self.class.the_ls_command == -1

      arguments = build_the_arguments_from config

      config[:command] = build_the_command_from arguments
      result = super event, config

      things = turn_the_ls_output_to_events result, config, event
      things
    end

    def build_the_command_from arguments
      command = self.class.the_ls_command
      "#{command} #{arguments.join(' ')}"
    end

    def build_the_arguments_from config
      arguments = ['-A', '-l', '--full-time', '-i']
      arguments << '-R' if config[:recursive].to_s == 'true'
      arguments << '-d' if config[:directory_only].to_s == 'true'
      arguments << "'#{config[:path]}'" if config[:path].to_s != ''
      arguments
    end

    def turn_the_ls_output_to_events result, config, event

      lines = result[:text].split("\n")

      needs_special_work_for_path = config[:directory_only].to_s != 'true' &&
                                    config[:path].to_s != '' &&
                                    lines[0] &&
                                    lines[0].start_with?('total ')

      origin = config[:directory] || Dir.pwd
      directory = needs_special_work_for_path ? '||DIRECTORY||' : origin

      things = lines.map do |x|
        segments = x.split ' '
        result = if segments.count > 5
                   pull_file segments, directory
                 elsif segments.count == 1
                   dir_segments = segments[0].split("\/")

                   if dir_segments[0] == '.'
                     dir_segments[0] = origin
                   else
                     dir_segments.unshift origin
                   end

                   dir_segments[-1] = dir_segments[-1].sub ':', ''
                   directory = dir_segments.join("\/")
                   nil
                 else
                   nil
                 end
      end.select { |x| x }

      if needs_special_work_for_path
        config[:directory_only] = true
        special_name = process(event, config)[0][:name]
        things.each do |x|
          [:directory, :path].each do |key|
            if x[key].include?('||DIRECTORY||')
              x[key].sub!('||DIRECTORY||', File.join(Dir.pwd, special_name))
            end
          end
        end
      end

      things
    end

    def pull_file segments, directory

      result = {}

      [:inode, :help, :hard_links, :owner, :group, :size].each do |key|
        result[key] = segments.shift; x = segments.join ' '
      end

      result.tap do |r|
        r[:date] = []
        3.times { r[:date] << segments.shift }
        r[:date] = r[:date].join ' '
        r[:date] = Time.parse r[:date]
      end

      result[:name] = segments.join ' '

      result.tap do |r|
        help_segments = r[:help].split ''
        r[:type] = help_segments[0]
        r[:owner_permission] = [1, 2, 3].map { |i| help_segments[i] }.reduce('') { |t, i| t + i }
        r[:group_permission] = [4, 5, 6].map { |i| help_segments[i] }.reduce('') { |t, i| t + i }
        r[:other_permission] = [7, 8, 9].map { |i| help_segments[i] }.reduce('') { |t, i| t + i }
        r.delete :help
      end

      [:hard_links, :size].each { |x| result[x] = result[x].to_i }

      result[:date] = Mushy::DateParts.parse result[:date]

      if File.exist?(result[:name]) && result[:name].start_with?(directory)
        result[:name] = result[:name].split("\/")[-1]
      end

      result[:directory] = directory

      if result[:type] == 'd' && result[:directory] == result[:name]
        result[:path] = result[:directory]
        name_segments = result[:name].split "\/"
        result[:name] = name_segments.pop
        result[:directory] = name_segments.join "\/"
      elsif result[:type] == 'd'
        result[:directory] = result[:name]
      else
        result[:path] = File.join result[:directory], result[:name]
      end

      result
    end

  end

end

