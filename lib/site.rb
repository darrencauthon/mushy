require 'sinatra'

require_relative 'mushy'

get '/' do
  #`pwd`
  #File.read(File.join('public', 'index.html'))
  #/home/pi/Desktop/mushy
  File.read(File.join(File.dirname(__FILE__), 'public', 'index.html'))
end

get '/steps' do
  content_type :json
  {
    steps: [
             Mushy::Bash.new,
           ].map { |x| x.details }
  }.to_json
end

post '/run' do
  content_type :json
  data = SymbolizedHash.new JSON.parse(request.body.read)
  step = Mushy::Workflow.build_step( { type: 'Browser', config: data[:config] } )
  { event: JSON.parse(data[:setup][:event]) }.to_json
end