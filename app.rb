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


  # use Rack::Auth::Basic do |username, password|
  #   if RUBY_PLATFORM =~ /mswin32/
  #     windows_authenticated?(username, 'northamerica', password)
  #   else
  #     true
  #   end
  # end

  configure :development do
      use Sinatra::Reloader
      use Sinatra::ShowExceptions
  end
  
  before do
  end

  helpers do

    def base_url
      if RUBY_PLATFORM =~ /mswin32/
        "#{env['rack.url_scheme']}://#{request.host_with_port}/iosapps"
      else
        "#{env['rack.url_scheme']}://#{request.host_with_port}"
      end
    end
    
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Merck App Store")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && is_valid_user?(@auth.credentials[0], 'northamerica', @auth.credentials[1])
    end
    
  end

  get '/install' do
    protected!
    @mfs = get_app_manifests
    erb :install
  end

  get '/' do
    @mfs = get_app_manifests
    erb :index
  end
    
  get '/index.plist' do
    @mfs = get_app_manifests

    content_type 'text/xml', :charset => 'utf-8'
    {'application_manifests' => @mfs}.to_plist
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