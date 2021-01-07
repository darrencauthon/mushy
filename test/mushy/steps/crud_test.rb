require_relative '../../test_helper.rb'

describe Mushy::Crud do

  let(:step) { Mushy::Crud.new }

  let(:event) { {} }

  before do
    step.config[:collection] = 'Elephants'
    step.config[:id] = 'id'
  end

  describe "upsert" do

    before do
      step.config[:operation] = 'upsert'
    end

    it "should insert the record into the appropriate collection" do

      event[:id] = SecureRandom.uuid
      event[:name] = SecureRandom.uuid

      result = step.execute event

      step.collections['Elephants'][event[:id]][:name].must_equal event[:name]

    end

    it "should allow multiple inserts" do

      event[:id] = SecureRandom.uuid
      event[:name] = SecureRandom.uuid

      event1 = { id: SecureRandom.uuid, name: SecureRandom.uuid }
      event2 = { id: SecureRandom.uuid, name: SecureRandom.uuid }
      step.execute event1
      step.execute event2

      step.collections['Elephants'].count.must_equal 2
      step.collections['Elephants'][event1[:id]][:name].must_equal event1[:name]
      step.collections['Elephants'][event2[:id]][:name].must_equal event2[:name]

    end

  end

end