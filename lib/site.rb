require 'sinatra'

require_relative 'mushy'

get '/' do
  File.read(File.join(File.dirname(__FILE__), 'public', 'index.html'))
end

get '/steps' do
  content_type :json
  {
    steps: Mushy::Step.all.select { |x| x.respond_to? :details }.map do |step|
                   details = step.details
                   details[:config][:limit] = { type: 'integer' }
                   details
                 end
  }.to_json
end

post '/run' do
  content_type :json

  data = SymbolizedHash.new JSON.parse(request.body.read)

  event = SymbolizedHash.new JSON.parse(data[:setup][:event].to_json)

  config = SymbolizedHash.new data[:config]

  step = Mushy::Workflow.build_step( { type: data[:setup][:step], config: config } )

  result = step.execute event

  result = [result].flatten

  { result: result }.to_json
end