require 'listen'

class Mushy::FileWatch < Mushy::Flux
  def self.details
    {
      name: 'FileWatch',
      title: 'Start a flow when files change',
      fluxGroup: { name: 'Starters', position: 0 },
      description: 'Watch for file changes.',
      config: {
        directory: {
          description: 'The directory to watch, defaults to the current directory.',
          type: 'text',
          shrink: true,
          value: ''
        },
        include_all_file_details: {
          description: 'If true, returns all details for the file. If false, just path & name are returned.',
          type: 'boolean',
          shrink: true,
          value: ''
        },
        merge_all_file_changes: {
          description: 'If true, all changes are merged into one "files". If false, added/modified/removed are returned separately.',
          type: 'boolean',
          shrink: true,
          value: ''
        },
        include_added: {
          description: 'Include added fields, defaults to true.',
          type: 'boolean',
          shrink: true,
          value: ''
        },
        include_modified: {
          description: 'Include modified fields, defaults to true.',
          type: 'boolean',
          shrink: true,
          value: ''
        },
        include_removed: {
          description: 'Include removed fields, defaults to true.',
          type: 'boolean',
          shrink: true,
          value: ''
        }
      },
      examples: {
        'Files Added' => {
          description: 'When a file is added, this type of result will be returned.',
          result: {
            modified: [],
            added: [{ path: '/home/pi/Desktop/mushy/bin/hey.txt', directory: '/home/pi/Desktop/mushy/bin', name: 'hey.txt' }],
            removed: []
          }
        },
        'Files Removed' => {
          description: 'When a file is deleted, this type of result will be returned.',
          result: {
            modified: [],
            added: [],
            removed: [{ path: '/home/pi/Desktop/mushy/mushy-0.15.3.gem', directory: '/home/pi/Desktop/mushy', name: 'mushy-0.15.3.gem'}]
          }
        },
        'Files Modified' => {
          description: 'When a file is modified, this type of result will be returned.',
          result: {
            modified: [{ path: '/home/pi/Desktop/mushy/lib/mushy/fluxs/environment.rb', directory: '/home/pi/Desktop/mushy/lib/mushy/fluxs/environment.rb', name: 'environment.rb' }],
            added: [],
            removed: []
          }
        }
      }
    }
  end

  def loop(&block)
    directory = config[:directory].to_s != '' ? config[:directory] : Dir.pwd

    listener = Listen.to(directory) do |modified, added, removed|
      block.call convert_changes_to_event(modified, added, removed, config)
    end

    listener.start

    sleep
  end

  def process(event, _)
    event
  end

  def test(_, config)
    modified = [Mushy::Ls.new.process({}, {}).select { |x| x[:type] == '-' }.sample]
               .compact
               .map { |x| x[:path] }
    convert_changes_to_event(modified, [], [], config)
  end

  def convert_changes_to_event(modified, added, removed, config)
    modified = [] if config[:include_modified].to_s == 'false'
    added = [] if config[:include_added].to_s == 'false'
    removed = [] if config[:include_removed].to_s == 'false'

    result = {
      modified: modified.map { |f| get_the_details_for(f, config) },
      added: added.map { |f| get_the_details_for(f, config) },
      removed: removed.map { |f| get_the_details_for(f, config) }
    }

    return result unless config[:merge_all_file_changes].to_s == 'true'

    {
      files: [:added, :modified, :removed].map { |x| result[x] }.flatten
    }
  end

  def get_the_details_for(file, config)
    if config[:include_all_file_details].to_s == 'true'
      Mushy::Ls.new.process({}, { path: file })[0]
    else
      segments = file.split("\/")
      {
        path: file,
        name: segments.pop,
        directory: segments.join("\/")
      }
    end
  end
end
