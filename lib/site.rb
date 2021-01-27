require 'sinatra'

require_relative 'mushy'

get '/' do
  Mushy::Builder::Index.file
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