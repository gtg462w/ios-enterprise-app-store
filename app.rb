require 'rubygems'
require 'pp'
require 'json'
require 'ostruct'
require 'sinatra'

require 'lib'

#use Rack::Auth::Basic do |username, password|
#    username == 'admin' && password == 'secret'
#end

#mime_type :ipa, 'application/octet-stream'
#mime_type :plist, 'application/octet-stream'

configure do
end

before do
end

helpers do
end

get '/' do
    @mfs = get_app_manifests
    erb :index
end

get '/mf/:name.plist' do
    #content_type 'text/xml', :charset => 'utf-8'
    @mf = get_app_manifest_by_name(params[:name])
    erb :app_manifest_plist
end