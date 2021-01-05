require_relative '../../test_helper.rb'

describe Mushy::ParseHtml do

  let(:step) { Mushy::ParseHtml.new }

  let(:event) do
    SymbolizedHash.new( {
      content: <<DOC
<html>
<head>
    <div id="abc"> 123 </div>
    <div id="efg">456</div>
</head>
</html>
DOC
    } )
  end

  let(:config) do
    {
      path: 'content',
      extract: {
        id:   'div|@id',
        text: 'div'
      }
    }
  end

  before do
    step.config = config
  end

  it "should allow css parsing" do
    result = step.execute event

    result.count.must_equal 2

    result[0][:id].must_equal 'abc'
    result[0][:text].must_equal '123'

    result[1][:id].must_equal 'efg'
    result[1][:text].must_equal '456'
  end

end