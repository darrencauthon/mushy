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
        result[:help]  = segments.shift; x = segments.join ' '

        help_segments = result[:help].split ''
        result[:type] = help_segments[0]
        result[:owner] = [1, 2, 3].map { |i| help_segments[i] }.reduce('') { |t, i| t + i }
        result[:group] = [4, 5, 6].map { |i| help_segments[i] }.reduce('') { |t, i| t + i }
        result[:other] = [7, 8, 9].map { |i| help_segments[i] }.reduce('') { |t, i| t + i }
        result.delete :help

        result.merge segments
         .each_with_index
         .reduce({}) { |t, i| t[i[1]] = i[0]; t }
      end

    end

  end

end

