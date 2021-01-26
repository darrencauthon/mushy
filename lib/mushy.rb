require 'liquid'
require 'symbolized'

Dir[File.dirname(__FILE__) + '/mushy/*.rb'].each { |f| require f }

important_flux_files = ['bash'].map { |x| "#{x}.rb" }
Dir[File.dirname(__FILE__) + '/mushy/fluxs/*.rb']
  .sort_by { |f| important_flux_files.any? { |x| f.end_with?(x) } ? 0 : 1 }
  .each { |f| require f }

module Mushy
  def self.hi
    puts 'hello'
  end
end