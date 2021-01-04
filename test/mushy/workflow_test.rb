require_relative '../test_helper.rb'

describe Mushy::Workflow do

  describe "parsing" do

    let(:data) do
      <<DOC
{
    "steps": [
                {}
             ]
}
DOC
    end

    it "should return a workflow" do
      Mushy::Workflow.parse(data)
        .is_a?(Mushy::Workflow).must_equal true
    end

    it "should have no steps" do
      Mushy::Workflow.parse(data)
        .steps.count.must_equal 0
    end

    it "should have an id" do
      id = Mushy::Workflow.parse(data).id
      id.nil?.must_equal false
      (id == '').must_equal false
    end

  end

end
