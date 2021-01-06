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
    #result = step.execute event

    #puts result.inspect
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

  describe "passing more complicated data through the liquid" do

    let(:event) do
      SymbolizedHash.new( {
        execute: "document.getElementById('txtLName').value = 'Cauthon';document.getElementById('btnSrchPartial').click();",
        url: 'about:blank'
      } )
    end

    let(:config) do
      {
        execute: "{{execute}}",
        url:     "{{url}}",
        headers: "{{headers}}",
        cookies: "{{cookies}}",
      }
    end

    before do
      step.config = config
    end

    it "should allow return information about the page" do

      return

      result = step.execute event

      step.config[:url] = 'about:blank/civroa.aspx?which=16CV04462'
      step.config[:execute] = nil

      result = step.execute result

      puts result[:url].inspect

    end

  end

end