Dir[File.dirname(__FILE__) + '/mushy/*.rb'].each { |f| require f }

module Mushy
  def self.hi
    puts 'hello'
  end
end