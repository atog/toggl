module TogglCmd
  
  class RunnerOptions < Hash
    attr_reader :opts

    def initialize(args)
      super()

      @opts = OptionParser.new do |o|
        o.banner = "Usage: #{File.basename($0)} [options]"

        o.on('-t', '--title TITLE', 'What do you want to register?') do |title|
          self[:description] = title
        end

        o.on('-p', '--project PROJECT', 'Who is going to pay?') do |project|
          self[:project] = project
        end

        o.on('-s', '--duration DURATION', 'How long did it take?') do |duration|
          self[:duration] = duration
        end

        o.on('-d', '--date DATE', 'When exactly did it happen?') do |date|
          self[:start] = date
        end
        
        o.on('-v', '--verbose', 'What\'s happening?') do |debug|
          self[:debug] = debug
        end
        
        o.on_tail('-h', '--help', 'Display this help and exit') do
          puts @opts
          exit
        end        

      end

      begin
        @opts.parse!(args)
      rescue OptionParser::InvalidOption => e
        self[:invalid_argument] = e.message
      end
    end
    
  end
end