require 'sinatra'

require_relative 'mushy'

get '/' do
  File.read(File.join(File.dirname(__FILE__), 'public', 'index.html'))
end

get '/fluxs' do
  content_type :json
  {
    fluxs: Mushy::Flux.all.select { |x| x.respond_to? :details }.map do |flux|
                   details = flux.details
                   details[:config][:split] = { type: 'text', description: 'Split one event into multiple events by this key.' }
                   details[:config][:merge] = { type: 'text', description: 'A comma-delimited list of fields from the event to carry through. Use * to merge all fields.' }
                   details[:config][:group] = { type: 'text', description: 'Group events by a field, which is stored in a key. The format is group_by|group_key.' }
                   details[:config][:limit] = { type: 'integer', description: 'Limit the number of events to this number.' }
                   details[:config][:join] = { type: 'text', description: 'Join all of the events from this flux into one event, under this name.' }
                   details[:config][:sort] = { type: 'text', description: 'Sort by this key.' }
                   details
                 end
  }.to_json
end

post '/run' do
  content_type :json

  data = SymbolizedHash.new JSON.parse(request.body.read)

  event = SymbolizedHash.new JSON.parse(data[:setup][:event].to_json)

  config = SymbolizedHash.new data[:config]

  flux = Mushy::Workflow.build_flux( { type: data[:setup][:flux], config: config } )

  result = flux.execute event

  result = [result].flatten

  { result: result }.to_json
end