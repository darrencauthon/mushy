require 'sinatra'

require_relative 'mushy'

the_file = 'hey.json'

get '/' do
  Mushy::Builder::Index.file
end

get '/dark.css' do
  content_type :css
  Mushy::Builder::Dark.file
end

get '/axios.js' do
  content_type :js
  Mushy::Builder::Axios.file
end

get '/vue.js' do
  content_type :js
  Mushy::Builder::Vue.file
end

get '/flow' do
  content_type :json
  Mushy::Builder::Api.get_flow(the_file).to_json
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

post '/save' do
  content_type :json

  result = Mushy::Builder::Api.save the_file, request.body.read

  { result: result }.to_json
end