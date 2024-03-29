module Mushy

  class GitLog < Bash

    def self.details
      {
        name: 'GitLog',
        title: 'Get git logs',
        description: 'Return git logs.',
        fluxGroup: { name: 'Git' },
        config: {
          directory: {
                       description: 'The working directory in which the command will be run.',
                       type:        'text',
                       shrink:      true,
                       value:       '',
                     },
          after: {
                   description: 'Filter for commits after this',
                   type:        'text',
                   shrink:      true,
                   value:       '',
                 },
          before: {
                   description: 'Filter for commits before this',
                   type:        'text',
                   shrink:      true,
                   value:       '',
                 },
          author: {
                   description: 'Filter for commits by this author',
                   type:        'text',
                   shrink:      true,
                   value:       '',
                 },
          committer: {
                   description: 'Filter for commits by this committer',
                   type:        'text',
                   shrink:      true,
                   value:       '',
                 },
        },
      }
    end

    def process event, config

      config[:command] = 'git log'

      if config[:directory].to_s != ''
        config[:command] = "cd \"#{config[:directory]}\";#{config[:command]}"
      end

      [:after, :before, :author, :committer]
        .select { |x| config[x].to_s != ''}
        .each   { |k| config[:command] = "#{config[:command]} --#{k}=\"#{config[k]}\"" }

      result = super event, config

      return result unless result[:success]

      result[:text].split("\n\n").reduce([]) do |results, line|
        if line.start_with? 'commit'
          results << { message: line.sub('commit', 'commit:') }
        else
          results[-1][:message] = results[-1][:message] + "\nMessage: " + line.strip
        end
        results
      end.map { |x| x[:message] }.map do |line|
        line.split("\n").reduce({}) do |t, i|
          segments = i.split ':'
          key = segments.shift.strip.downcase.to_sym
          t[key] = segments.map { |y| y.strip }.join ':'
          t
        end
      end.map do |commit|
        commit.tap do |x|
          segments = x[:author].split '<'
          x[:author_name] = segments.shift.strip
          x[:author_email] = segments.join('').strip.gsub('>', '')
        end
      end

    end

  end

end