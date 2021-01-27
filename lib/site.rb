require 'sinatra'

require_relative 'mushy'

get '/' do
  File.read(File.join(File.dirname(__FILE__), 'public', 'index.html'))
end

get '/fluxs' do
  content_type :json
  Mushy::Builder::Api.get_fluxs.to_json
end

post '/run' do
  content_type :json

  result = Mushy::Builder::Api.run request.body.read

  { result: result }.to_json
end