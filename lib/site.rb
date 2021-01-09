require 'sinatra'

require_relative 'mushy'

get '/steps' do
  content_type :json
  {
    steps: [
             Mushy::Bash.new,
           ].map { |x| x.details }
  }.to_json
end