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

      arguments = ['-A', '-l', '--full-time', '-i']
      arguments << '-R' if config[:recursive].to_s == 'true'
      arguments << config[:path] if config[:path].to_s != ''
      config[:command] = "ls #{arguments.join(' ')}"

      result = super event, config

      return result unless result[:success]

      lines = result[:text].split("\n")

      origin = config[:directory] || Dir.pwd
      directory = origin
      lines.map do |x|
        segments = x.split ' '
        result = if segments.count > 5
                   pull_file segments, directory
                 elsif segments.count == 1
                   dir_segments = segments[0].split("\/")
                   dir_segments[0] = origin if dir_segments[0] == '.'
                   dir_segments[-1] = dir_segments[-1].sub ':', ''
                   directory = dir_segments.join("\/")
                   nil
                 else
                   nil
                 end
      end.select { |x| x }

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

      result[:date_parts] = Mushy::DateParts.parse result[:date]

      result[:directory] = directory
      result[:path] = File.join result[:directory], result[:name]

      result
    end

  end

end

