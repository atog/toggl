require "optparse"
require "chronic_duration"

module TogglCmd

  NAME = "toggl-gem"
  PROJECT_FIELDS = %w(client name)
  TASK_FIELDS = %w(id project description start duration billable)

  class Runner

    def self.toggl(args)
      token = IO.readlines(File.expand_path("~/.toggl")).join.strip
      options = RunnerOptions.new(args)
      if options[:tasks]
        prettify_tasks(Toggl.new(token, NAME).tasks)
      elsif options[:projects]
        prettify_projects(Toggl.new(token, NAME).projects)
      elsif options[:delete]
        toggl = Toggl.new(token, NAME)
        toggl.delete_task(options[:delete])
        prettify_tasks(toggl.tasks)
      elsif options.any?
        prettify_tasks(Toggl.new(token, NAME, options.delete(:debug)).create_task(options))
      else
        puts options.opts
      end
    end

    private

    def self.prettify_tasks(values)
      values = [values] unless values.is_a?(Array)
      values.each do |value|
        value["project"]    = value["project"]["name"]
        value["workspace"]  = value["workspace"]["name"]
        value["duration"] = ChronicDuration.output(value["duration"].to_i, :format => :short)
        value["start"] = value["start"].strftime("%d/%m/%Y")
      end
      values.view(:class => :table, :fields => TASK_FIELDS)
    end

    def self.prettify_projects(values)
      values.view(:class => :table, :fields => PROJECT_FIELDS)
    end

  end

end
