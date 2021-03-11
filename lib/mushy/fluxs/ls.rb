module Mushy

  class Ls < Bash

    def self.details
      {
        name: 'Ls',
        description: 'Run the "ls" command.',
        config: Mushy::Bash.details[:config].tap { |c| c.delete :command },
      }
    end

    def process event, config

      config[:command] = 'ls -A -l --full-time -i'

      result = super event, config

      return result unless result[:success]

      lines = result[:text].split("\n")
      lines.shift

      lines.map do |x|
        result = {}
        segments = x.split ' '

        result[:inode] = segments.shift; x = segments.join ' '
        result[:help] = segments.shift; x = segments.join ' '
        result[:hard_links] = segments.shift; x = segments.join ' '
        result[:owner] = segments.shift; x = segments.join ' '
        result[:group] = segments.shift; x = segments.join ' '
        result[:size] = segments.shift; x = segments.join ' '

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

        result[:date_parts] = Mushy::Interval.time_from result[:date]

        result[:directory] = config[:directory] || Dir.pwd
        result[:path] = File.join result[:directory], result[:name]

        result
      end

    end

  end

end

