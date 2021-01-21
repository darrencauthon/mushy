require 'liquid'
require 'symbolized'

Dir[File.dirname(__FILE__) + '/mushy/*.rb'].each { |f| require f }
Dir[File.dirname(__FILE__) + '/mushy/fluxs/*.rb'].each { |f| require f }

module Mushy
  def self.hi
    puts 'hello'
  end
end