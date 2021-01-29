require_relative '../test_helper.rb'

describe Mushy::Flow do

  describe "parsing" do

    let(:data) do
      <<DOC
{
}
DOC
    end

    it "should return a flow" do
      Mushy::Flow.parse(data)
        .is_a?(Mushy::Flow).must_equal true
    end

    it "should have no fluxs" do
      Mushy::Flow.parse(data)
        .fluxs.count.must_equal 0
    end

    it "should have an id" do
      id = Mushy::Flow.parse(data).id
      id.nil?.must_equal false
      (id == '').must_equal false
    end

    describe "fluxs" do

      let(:data) do
        <<DOC
{
    "fluxs": [
        { "id": "abcd", "config": { "a": "b"} },
        { "id": "efgh", "config": { "c": "d" }, "parent_fluxs": ["abcd"], "type": "Get" }
    ]
}
DOC
      end

      describe "the types of fluxs" do
        it "should default the type to Flux" do
          Mushy::Flow.parse(data).fluxs[0].class.must_equal Mushy::Flux
        end

        it "should allow the type to be overwritten" do
          Mushy::Flow.parse(data).fluxs[1].class.must_equal Mushy::Get
        end
      end

      describe "parent fluxs" do

        it "should load the parent fluxs" do
          fluxs = Mushy::Flow.parse(data).fluxs
          fluxs[0].parent_fluxs.count.must_equal 0
          fluxs[1].parent_fluxs.count.must_equal 1
          fluxs[1].parent_fluxs[0].must_be_same_as fluxs[0]
        end

        describe "parent fluxes with just one parent" do

          describe "fluxs" do

            let(:data) do
<<DOC
{
    "fluxs": [
        { "id": "abcd", "config": { "a": "b"} },
        { "id": "efgh", "config": { "c": "d" }, "parent": "abcd", "type": "Get" }
    ]
}
DOC
            end

            it "should load the parent fluxs" do
              fluxs = Mushy::Flow.parse(data).fluxs
              fluxs[0].parent_fluxs.count.must_equal 0
              fluxs[1].parent_fluxs.count.must_equal 1
              fluxs[1].parent_fluxs[0].must_be_same_as fluxs[0]
            end

          end

        end

      end

      describe "missing flux data" do

        let(:data) do
        <<DOC
{
    "fluxs": [
        {}
    ]
}
DOC
        end

        it "should set a temp id" do
          fluxs = Mushy::Flow.parse(data).fluxs
          (fluxs[0].id.nil?).must_equal false
          (fluxs[0].id == '').must_equal false
        end

        it "should set default config" do
          fluxs = Mushy::Flow.parse(data).fluxs
          (fluxs[0].config.nil?).must_equal false
        end

        it "should set default parents" do
          fluxs = Mushy::Flow.parse(data).fluxs
          fluxs[0].parent_fluxs.count.must_equal 0
        end
      end

      it "should have two fluxs" do
        fluxs = Mushy::Flow.parse(data).fluxs
        fluxs.count.must_equal 2
      end

      it "should load the id" do
        fluxs = Mushy::Flow.parse(data).fluxs
        fluxs[0].id.must_equal 'abcd'
        fluxs[1].id.must_equal 'efgh'
      end

      describe "config" do

        it "should load the config" do
          fluxs = Mushy::Flow.parse(data).fluxs
          fluxs[0].config['a'].must_equal 'b'
          fluxs[1].config['c'].must_equal 'd'
        end

        it "should load the config with symbols" do
          fluxs = Mushy::Flow.parse(data).fluxs
          fluxs[0].config[:a].must_equal 'b'
          fluxs[1].config[:c].must_equal 'd'
        end

      end

    end

  end

end