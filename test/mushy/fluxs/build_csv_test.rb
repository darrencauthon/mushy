require_relative '../../test_helper.rb'

describe Mushy::BuildCsv do

  let(:flux) { Mushy::BuildCsv.new }

  let(:event) { {} }

  let(:config) { {} }

  it "should allow the building of content" do

    config[:input_path] = 'data'
    config[:output_path] = 'the_output'
    config[:headers] = { a: 'A', b: 'B' }
    config[:header_row] = true

    event[:data] = [
      { a: '1', b: '2' },
      { a: '3', b: '4' },
    ]

    result = flux.process event, config

  end

end
