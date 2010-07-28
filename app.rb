require 'rubygems'
require 'pp'
require 'json'
require 'ostruct'
require 'sinatra/base'
require 'plist'
require 'lib'

class Sinatra::Reloader < Rack::Reloader
  def safe_load(file, mtime, stderr = $stderr)
    ::Sinatra::Application.reset!
    super
  end
end

class MyApp < Sinatra::Base

  set :public, './public'

  configure :development do
      use Sinatra::Reloader
      use Sinatra::ShowExceptions
  end
  
  before do
  end

  helpers do

    def base_url
      "#{env['rack.url_scheme']}://#{request.host_with_port}"
    end

  end

  get '/' do
    @mfs = get_app_manifests
    erb :index
  end
    
  get '/index.plist' do
    @mfs = get_app_manifests

    content_type 'text/xml', :charset => 'utf-8'
    @mfs.to_plist
  end

  get '/mf/:name.plist' do
    content_type 'text/xml', :charset => 'utf-8'
    @mf = get_app_manifest_by_name(params[:name])
    erb :app_manifest_plist
  end
  
  get '/admin' do
  end
  
  get '/debug' do
    "#{request.host_with_port}"
  end
    
end

if __FILE__ == $0
  MyApp.run!
end