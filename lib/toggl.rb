require "rubygems"
require "httparty"
require "chronic_duration"
require "multi_json"
require "pp"
class Toggl
  include HTTParty
  base_uri "https://www.toggl.com"
  format :json
  headers  "Content-Type" => "application/json"

  attr_reader :name, :api_token

  def initialize(token, name="toggl-gem", debug=false)
    self.class.default_params :output => 'json'
    @api_token = token
    @name = name
    self.class.debug_output if debug
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
      when "today"
        Date.today
      when "yesterday"
        Date.today - 1
      when "tomorrow"
        Date.today + 1
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

  def time_entries(params={})
    get 'time_entries', params
  end

  def get_time_entry(id)
    get "time_entries/#{id}"
  end

  def create_time_entry(params={})
    workspace   = params[:workspace] || default_workspace_id
    project_id  = find_project_id(params[:project]) || create_project(params, workspace)
    params[:billable] = true
    params[:start] = Time.now if params[:start].nil?
    params[:start] = params[:start].iso8601
    params.merge!({ :created_with => name,
                    :workspace => {:id => workspace},
                    :project => {:id => project_id},
                    :tag_names => [name]})

    post 'time_entries', MultiJson.encode({:time_entry => params})
  end

  def update_time_entry(params={})
    put "time_entries/#{params['id']}", MultiJson.encode({:time_entry => params})
  end

  def delete_time_entry(id)
    self.class.delete("/api/v6/time_entries/#{id}.json", :basic_auth => basic_auth)
  end

  def clients
    get 'clients'
  end

  def create_client(params={})
    post "clients", MultiJson.encode({:client => params})
  end

  def update_client(params={})
    put "clients/#{params['id']}", MultiJson.encode({:client => params})
  end

  def delete_client(id)
    delete "clients/#{id}"
  end

  def projects
    get 'projects'
  end

  def create_project(params={})
    post "projects", MultiJson.encode({:project => params})
  end

  def update_project(params={})
    put "projects/#{params['id']}", MultiJson.encode({:project => params})
  end

  def create_project_user(params={})
    post "project_users", MultiJson.encode({:project_user => params})
  end

  def tasks
    get 'tasks'
  end

  def create_task(params={})
    post "tasks", MultiJson.encode({:task => params})
  end

  def update_task(params={})
    put "tasks/#{params['id']}", MultiJson.encode({:task => params})
  end

  def delete_task(id)
    delete "tasks/#{id}"
  end

  def tags
    get 'tags'
  end

  private
  
  def get(resource_name, data={})
    response = self.class.get("/api/v6/#{resource_name}.json", :basic_auth => basic_auth, :query => data)
    response['data'].nil? ? response : response['data'] 
  end

  def post(resource_name, data)
    response = self.class.post("/api/v6/#{resource_name}.json", :body => data, :basic_auth => basic_auth,
      :options => { :headers => {"Content-type" => "application/json"}})
    response['data'].nil? ? response : response['data'] 
  end

  def put(resource_name, data)
    response = self.class.put("/api/v6/#{resource_name}.json", :body => data, :basic_auth => basic_auth,
      :options => { :headers => {"Content-type" => "application/json"}})
    response['data'].nil? ? response : response['data'] 
  end

  def delete(resource_name, id)
    self.class.delete("/api/v6/#{resource_name}/#{id}.json", :basic_auth => basic_auth)
  end

  def basic_auth
    {:username => self.api_token, :password => "api_token"}
  end

end
