require "rubygems"
require "httparty"
require "chronic_duration"

class Toggl
  include HTTParty
  base_uri "https://toggl.com"
  format :json
  # debug_output
  
  attr_reader :name
  
  def initialize(token, name="toggl-gem")
    self.class.default_params :output => 'json', :api_token => token
    @name = name
  end
    
  def create_task(params={})
    workspace   = params[:workspace] || default_workspace_id
    project_id  = find_project_id(params[:project]) || create_project(params, workspace)
    
    params.merge!({ :created_with => name, 
                    :workspace => {:id => workspace}, 
                    :project => {:id => project_id}, 
                    :tag_names => [name], 
                    :start => start(params[:start]), 
                    :duration => duration(params[:duration])})
                    
    self.class.post("/api/tasks.json", :body => {:task => params})
  end
  
  def create_project(params={}, workspace=nil)
    workspace ||= default_workspace_id
    if project = self.class.post("/api/projects.json", :body => {
                      :project => {:name => params[:project], 
                                   :workspace => {:id => workspace}, 
                                   :billable => (params[:billable] || true)}})
       project["id"]
     end
  end
  
  def default_workspace_id
    self.workspaces.first["id"]
  end
  
  def find_project_id(str)
    if project = self.projects.find{|project| project["client_project_name"].downcase =~ /#{str}/}
      project["id"]
    end
  end
  
  def duration(str)
    str ? ChronicDuration.parse(str) : 1800
  end
  
  def start(value)
    if value
      case value
      when "today"    : Date.today
      when "yesterday": Date.today - 1
      when "tomorrow" : Date.today + 1
      else
        DateTime.parse(value)
      end
    else
      DateTime.now
    end
  end
  
  def workspaces
    self.class.get("/api/workspaces.json")
  end
  
  def tasks
    self.class.get("/api/tasks.json")
  end
  
  def projects
    self.class.get("/api/projects.json")
  end
end