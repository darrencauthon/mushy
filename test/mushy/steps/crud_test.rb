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

  end

end