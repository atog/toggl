require "rubygems"
require "httparty"
require "chronic_duration"

class Toggl
  include HTTParty
  base_uri "https://toggl.com"
  format :json

  attr_reader :name, :api_token

  def initialize(token, name="toggl-gem", debug=false)
    self.class.default_params :output => 'json'
    @api_token = token
    @name = name
    self.class.debug_output if debug
  end

  def delete_task(task_id)
    delete 'tasks', task_id
  end

  def create_task(params={})
    workspace   = params[:workspace] || default_workspace_id
    project_id  = find_project_id(params[:project]) || create_project(params, workspace)
    params[:billable] = true

    params.merge!({ :created_with => name,
                    :workspace => {:id => workspace},
                    :project => {:id => project_id},
                    :tag_names => [name],
                    :start => start(params[:start]),
                    :duration => duration(params[:duration])})

    post 'tasks', {:task => params}
  end

  def create_project(params={}, workspace=nil)
    workspace ||= default_workspace_id
    if project = post("projects",
                      :project => {:name => params[:project],
                                   :workspace => {:id => workspace},
                                   :billable => (params[:billable] || true)})
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
    get 'workspaces'
  end

  def tasks(params={})
    get 'tasks', params
  end

  def projects
    get 'projects'
  end

  private

  def get(resource_name, data={})
    self.class.get("/api/v1/#{resource_name}.json", :basic_auth => basic_auth, :query => data)
  end

  def post(resource_name, data)
    self.class.post("/api/v1/#{resource_name}.json", :body => data, :basic_auth => basic_auth)
  end

  def delete(resource_name, id)
    self.class.delete("/api/v1/#{resource_name}/#{id}.json", :basic_auth => basic_auth)
  end

  def basic_auth
    {:username => self.api_token, :password => "api_token"}
  end

end
