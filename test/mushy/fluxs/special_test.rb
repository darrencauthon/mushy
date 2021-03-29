require_relative '../../test_helper.rb'

describe Mushy::Special do

  let(:flux) { Mushy::Special.new }

  let(:event) { {} }

  before do
    flux.config[:id] = 'id'
  end

  #describe "upsert" do

    #before do
      #flux.config[:operation] = 'upsert'
    #end

    #it "should insert the record" do

      #event[:id] = SecureRandom.uuid
      #event[:name] = SecureRandom.uuid

      #result = flux.execute event

      #flux.collection[event[:id]][:name].must_equal event[:name]

    #end

    #it "should return the event passed to it" do

      #key, value = SecureRandom.uuid, SecureRandom.uuid

      #event[:id] = SecureRandom.uuid
      #event[:name] = SecureRandom.uuid
      #event[key] = value

      #result = flux.execute event

      #result[key].must_equal value

    #end

    #it "should allow multiple inserts" do

      #event[:id] = SecureRandom.uuid
      #event[:name] = SecureRandom.uuid

      #event1 = { id: SecureRandom.uuid, name: SecureRandom.uuid }
      #event2 = { id: SecureRandom.uuid, name: SecureRandom.uuid }
      #flux.execute event1
      #flux.execute event2

      #flux.collection.count.must_equal 2
      #flux.collection[event1[:id]][:name].must_equal event1[:name]
      #flux.collection[event2[:id]][:name].must_equal event2[:name]

    #end

    #it "should merge when ids match" do

      #event[:id] = SecureRandom.uuid
      #event[:name] = SecureRandom.uuid

      #event1 = { id: SecureRandom.uuid, first_name: SecureRandom.uuid, middle: 'A' }
      #event2 = { id: event1[:id],       last_name: SecureRandom.uuid,  middle: 'B' }
      #flux.execute event1
      #flux.execute event2

      #flux.collection.count.must_equal 1
      #flux.collection[event1[:id]][:first_name].must_equal event1[:first_name]
      #flux.collection[event1[:id]][:last_name].must_equal event2[:last_name]
      #flux.collection[event1[:id]][:middle].must_equal 'B'

    #end

    #describe "returning the result of the operation" do

      #it "should return the result of the operation using the provided key" do
        #key = SecureRandom.uuid
        #flux.config[:operation_performed] = key

        #event[:id] = SecureRandom.uuid
        #event[:name] = SecureRandom.uuid

        #event1 = { id: SecureRandom.uuid, first_name: SecureRandom.uuid, middle: 'A' }
        #event2 = { id: event1[:id],       last_name: SecureRandom.uuid,  middle: 'B' }
        #result1 = flux.execute event1
        #result2 = flux.execute event2

        #result1[key].must_equal "inserted"
        #result2[key].must_equal "updated"

      #end

    #end

  #end

  #describe "delete" do

    #before do
      #flux.config[:operation] = 'delete'
    #end

    #it "should delete by the id" do

      #event[:id] = SecureRandom.uuid

      #flux.collection[event[:id]] = {}
      #flux.collection[SecureRandom.uuid] = {}

      #flux.execute event

      #flux.collection.count.must_equal 1

    #end

    #it "should return the event passed to it" do

      #key, value = SecureRandom.uuid, SecureRandom.uuid

      #event[:id] = SecureRandom.uuid
      #event[key] = value

      #flux.collection[event[:id]] = {}
      #flux.collection[SecureRandom.uuid] = {}

      #result = flux.execute event

      #result[key].must_equal value

    #end

    #it "should return the operation performed" do

      #key = SecureRandom.uuid
      #flux.config[:operation_performed] = key

      #event[:id] = SecureRandom.uuid

      #flux.collection[event[:id]] = {}
      #flux.collection[SecureRandom.uuid] = {}

      #result = flux.execute event

      #result[key].must_equal 'deleted'

    #end

  #end

  #describe "all" do

    #before do
      #flux.config[:operation] = 'all'
    #end

    #it "should return all of the items" do

      #flux.collection['a'] = { a: 1 }
      #flux.collection['b'] = { b: 2 }
      #flux.collection['c'] = { c: 3 }

      #results = flux.execute event

      #results.count.must_equal 3
      #results[0][:a].must_equal 1
      #results[1][:b].must_equal 2
      #results[2][:c].must_equal 3

    #end

  #end

  #describe "update" do

    #before do
      #flux.config[:operation] = 'update'
    #end

    #it "should should not throw if the record does not exist" do

      #event[:id] = SecureRandom.uuid
      #event[:name] = SecureRandom.uuid

      #flux.execute event

    #end

    #it "should should report back the operation as not exists if the record does not exist" do

      #key = SecureRandom.uuid
      #flux.config[:operation_performed] = key

      #event[:id] = SecureRandom.uuid

      #result = flux.execute event

      #result[key].must_equal 'not exist'

    #end

  #end

end