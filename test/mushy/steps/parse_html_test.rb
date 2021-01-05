require_relative '../../test_helper.rb'

describe Mushy::ParseHtml do

  let(:step) { Mushy::ParseHtml.new }

  let(:event) do
    {
        content: <<DOC
<html>
<head>
    <div id="abc">123</div>
    <div id="efg">456</div>
</head>
</html>
DOC
    }
  end

  let(:config) { {} }

  it "should allow css parsing" do
    result = step.process event, config
    result.count.must_equal 2
  end

end