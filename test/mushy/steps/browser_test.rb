require_relative '../../test_helper.rb'

describe Mushy::Browser do

  let(:step) { Mushy::Browser.new }

  let(:event) do
    SymbolizedHash.new( {
    } )
  end

  let(:config) do
    {
      url: 'http://www.google.com'
    }
  end

  before do
    step.config = config
  end

  it "should allow return information about the page" do
    result = step.execute event

    puts result.inspect
  end

  describe "passing headers" do

    before do
      config[:headers] = { test: 'abcd' }
    end

    it "should allow return information about the page" do
      #result = step.execute event

      #puts result[:headers].inspect
    end

  end
end