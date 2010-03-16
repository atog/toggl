require "optparse"

module TogglCmd
  
  NAME = "toggl-gem"
  
  class Runner
    
    def self.toggl(args)
      token = IO.readlines(File.expand_path("~/.toggl")).join.strip
      options = RunnerOptions.new(args)
      if options[:tasks]
        puts Toggl.new(token, NAME).tasks
      elsif options[:projects]        
        puts Toggl.new(token, NAME).projects
      elsif options.any?        
        Toggl.new(token, NAME, options.delete(:debug)).create_task(options)
      else
        puts options.opts
      end
    end
        
  end
  
end