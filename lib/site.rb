require 'sinatra'

require_relative 'mushy'

get '/' do
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

  event = JSON.parse(data[:setup][:event])
  step = Mushy::Workflow.build_step( { type: 'Browser', config: data[:config] } )

  result = step.execute event

  { result: result }.to_json
end