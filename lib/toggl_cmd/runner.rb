require "optparse"

module TogglCmd
  
  class Runner
    
    def self.toggl(args)
      token = IO.readlines(File.expand_path("~/.toggl")).join
      options = RunnerOptions.new(args)
      if options[:tasks]
        puts Toggl.new(token, "toggl-gem").tasks
      elsif options[:projects]        
        puts Toggl.new(token, "toggl-gem").projects
      elsif options.any?        
        Toggl.new(token, "toggl-gem", options.delete(:debug)).create_task(options)
      else
        puts options.opts
      end
    end
        
  end
  
end