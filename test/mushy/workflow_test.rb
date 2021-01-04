require_relative '../test_helper.rb'

describe Mushy::Workflow do

  describe "parsing" do

    let(:data) do
      <<DOC
{
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

    describe "steps" do

      let(:data) do
        <<DOC
{
    "steps": [
        { "id": "abcd", "config": { "a": "b"} },
        { "id": "efgh", "config": { "c": "d" } }
    ]
}
DOC
      end

      it "should have two steps" do
        steps = Mushy::Workflow.parse(data).steps
        steps.count.must_equal 2
      end

      it "should load the id" do
        steps = Mushy::Workflow.parse(data).steps
        steps[0].id.must_equal 'abcd'
        steps[1].id.must_equal 'efgh'
      end

      describe "config" do
        it "should load the config" do
          steps = Mushy::Workflow.parse(data).steps
          steps[0].config['a'].must_equal 'b'
          steps[1].config['c'].must_equal 'd'
        end

        it "should load the config with symbols" do
          steps = Mushy::Workflow.parse(data).steps
          steps[0].config[:a].must_equal 'b'
          steps[1].config[:c].must_equal 'd'
        end

      end

    end

  end

end