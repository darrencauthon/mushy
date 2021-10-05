module Mushy
  module Builder
    module Documentation

      def self.build_from config
        basic_usage = "#{config[:description]}"
        if config[:config]&.any?
          rows = config[:config]
                   .map { |x| [x[0], x[1][:description], (x[1][:shrink] ? '(optional) ' : '')] }
                   .reduce("") { |t, i| "#{t}<tr><td>#{i[0]}</td><td>#{i[2]}#{i[1]}</td></tr>" }
          basic_usage += '<table class="table is-bordered"><thead><tr><td>Field</td><td>Description</td></tr></thead>' + rows + "</table>"
        end

        {
          "Basic Usage" => basic_usage,
        }.tap do |documentation|
          if config[:examples]
            config[:examples].each do |item|
              documentation[item[0]] = [
                item[1][:description],
                code_sample('Input', item[1][:input]),
                code_sample('Result', item[1][:result]),
              ].select { |x| x }.reduce('') { |t, i| t + i }
            end
          end
        end
      end

      def self.code_sample title, value
        return nil unless value
        "<div><b>#{title}</b></div><pre><code>#{JSON.pretty_generate(value)}</code></pre>"
      end

    end
  end
end