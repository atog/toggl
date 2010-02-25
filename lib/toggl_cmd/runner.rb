require "optparse"

module TogglCmd
  
  class Runner
    
    def self.toggl(args)
      options = RunnerOptions.new(args)
      if options.any?
        token = IO.readlines(File.expand_path("~/.toggl")).join
        Toggl.new(token, "toggl-gem", options.delete(:debug)).create_task(options)
      else
        puts options.opts
      end
    end
        
  end
  
end