require 'liquid'
require 'symbolized'

Dir[File.dirname(__FILE__) + '/mushy/*.rb'].each { |f| require f }

important_flux_files = [
                        'bash',
                        'browser',
                        'simple_python_program',
                       ].map { |x| "#{x}.rb" }

Dir[File.dirname(__FILE__) + '/mushy/fluxs/*.rb']
  .map     { |x| [x, important_flux_files.find_index(x.split("\/")[-1]) || 9999999] }
  .sort_by { |x| x[1] }
  .map     { |x| x[0] }
  .each    { |f| require f }

Dir[File.dirname(__FILE__) + '/mushy/builder/*.rb'].each { |f| require f }