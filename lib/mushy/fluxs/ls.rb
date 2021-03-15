module Mushy

  class Ls < Bash

    def self.details
      {
        name: 'Ls',
        description: 'Run the "ls" command.',
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
      end
    end

    def process event, config
      arguments = build_the_arguments_from config

      config[:command] = build_the_command_from arguments
      result = super event, config

      things = turn_the_ls_output_to_events result, config, event
      things
    end

    def build_the_command_from arguments
      "ls #{arguments.join(' ')}"
    end

    def build_the_arguments_from config
      arguments = ['-A', '-l', '--full-time', '-i']
      arguments << '-R' if config[:recursive].to_s == 'true'
      arguments << '-d' if config[:directory_only].to_s == 'true'
      arguments << config[:path] if config[:path].to_s != ''
      arguments
    end

    def turn_the_ls_output_to_events result, config, event

      lines = result[:text].split("\n")

      needs_special_work_for_path = config[:directory_only].to_s != 'true' &&
                                    config[:path].to_s != '' &&
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

      result[:name] = segments.shift

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

      result[:directory] = directory
      result[:path] = File.join result[:directory], result[:name]

      result
    end

  end

end

