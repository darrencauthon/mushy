require_relative '../../test_helper.rb'

describe Mushy::Browser do

  let(:flux) { Mushy::Browser.new }

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
    flux.config = config
  end

  #it "should allow return information about the page" do
    #result = flux.execute event
  #end

  describe "passing headers" do

    before do
      config[:headers] = { test: 'abcd' }
    end

    #it "should allow return information about the page" do
      #result = flux.execute event
    #end

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
      flux.config = config
    end

    #it "should allow return information about the page" do

      #return

      #result = flux.execute event

      #flux.config[:url] = 'about:blank'
      #flux.config[:execute] = nil

      #result = flux.execute result

    #end

  end

end