require_relative '../../test_helper.rb'

describe Mushy::Collection do

  let(:step) { Mushy::Collection.new }

  let(:event) { {} }

  before do
    step.config[:id] = 'id'
  end

  describe "upsert" do

    before do
      step.config[:operation] = 'upsert'
    end

    it "should insert the record" do

      event[:id] = SecureRandom.uuid
      event[:name] = SecureRandom.uuid

      result = step.execute event

      step.collection[event[:id]][:name].must_equal event[:name]

    end

    it "should return the event passed to it" do

      key, value = SecureRandom.uuid, SecureRandom.uuid

      event[:id] = SecureRandom.uuid
      event[:name] = SecureRandom.uuid
      event[key] = value

      result = step.execute event

      result[key].must_equal value

    end

    it "should allow multiple inserts" do

      event[:id] = SecureRandom.uuid
      event[:name] = SecureRandom.uuid

      event1 = { id: SecureRandom.uuid, name: SecureRandom.uuid }
      event2 = { id: SecureRandom.uuid, name: SecureRandom.uuid }
      step.execute event1
      step.execute event2

      step.collection.count.must_equal 2
      step.collection[event1[:id]][:name].must_equal event1[:name]
      step.collection[event2[:id]][:name].must_equal event2[:name]

    end

    it "should merge when ids match" do

      event[:id] = SecureRandom.uuid
      event[:name] = SecureRandom.uuid

      event1 = { id: SecureRandom.uuid, first_name: SecureRandom.uuid, middle: 'A' }
      event2 = { id: event1[:id],       last_name: SecureRandom.uuid,  middle: 'B' }
      step.execute event1
      step.execute event2

      step.collection.count.must_equal 1
      step.collection[event1[:id]][:first_name].must_equal event1[:first_name]
      step.collection[event1[:id]][:last_name].must_equal event2[:last_name]
      step.collection[event1[:id]][:middle].must_equal 'B'

    end

    describe "returning the result of the operation" do

      it "should return the result of the operation using the provided key" do
        key = SecureRandom.uuid
        step.config[:operation_performed] = key

        event[:id] = SecureRandom.uuid
        event[:name] = SecureRandom.uuid

        event1 = { id: SecureRandom.uuid, first_name: SecureRandom.uuid, middle: 'A' }
        event2 = { id: event1[:id],       last_name: SecureRandom.uuid,  middle: 'B' }
        result1 = step.execute event1
        result2 = step.execute event2

        result1[key].must_equal "inserted"
        result2[key].must_equal "updated"

      end

    end

  end

  describe "delete" do

    before do
      step.config[:operation] = 'delete'
    end

    it "should delete by the id" do

      event[:id] = SecureRandom.uuid

      step.collection[event[:id]] = {}
      step.collection[SecureRandom.uuid] = {}

      step.execute event

      step.collection.count.must_equal 1

    end

    it "should return the event passed to it" do

      key, value = SecureRandom.uuid, SecureRandom.uuid

      event[:id] = SecureRandom.uuid
      event[key] = value

      step.collection[event[:id]] = {}
      step.collection[SecureRandom.uuid] = {}

      result = step.execute event

      result[key].must_equal value

    end

    it "should return the operation performed" do

      key = SecureRandom.uuid
      step.config[:operation_performed] = key

      event[:id] = SecureRandom.uuid

      step.collection[event[:id]] = {}
      step.collection[SecureRandom.uuid] = {}

      result = step.execute event

      result[key].must_equal 'deleted'

    end

  end

  describe "all" do

    before do
      step.config[:operation] = 'all'
    end

    it "should return all of the items" do

      step.collection['a'] = { a: 1 }
      step.collection['b'] = { b: 2 }
      step.collection['c'] = { c: 3 }

      results = step.execute event

      results.count.must_equal 3
      results[0][:a].must_equal 1
      results[1][:b].must_equal 2
      results[2][:c].must_equal 3

    end

  end

  describe "update" do

    before do
      step.config[:operation] = 'update'
    end

    it "should should not throw if the record does not exist" do

      event[:id] = SecureRandom.uuid
      event[:name] = SecureRandom.uuid

      step.execute event

    end

    it "should should report back the operation as not exists if the record does not exist" do

      key = SecureRandom.uuid
      step.config[:operation_performed] = key

      event[:id] = SecureRandom.uuid

      result = step.execute event

      result[key].must_equal 'not exist'

    end

  end

end