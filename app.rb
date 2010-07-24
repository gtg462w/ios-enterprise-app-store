require 'rubygems'
require 'pp'
require 'json'
require 'ostruct'
require 'sinatra/base'
require 'plist'
require 'lib'

class MyApp < Sinatra::Base

  set :public, './public'

  configure do
  end

  before do
  end

  helpers do

    def base_url
      "#{env['rack.url_scheme']}://#{env['SERVER_NAME']}:#{env['SERVER_PORT']}"
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
    
end

if __FILE__ == $0
  MyApp.run!
end