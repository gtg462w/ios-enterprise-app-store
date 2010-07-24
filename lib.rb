require 'rubygems'
require 'pp'
require 'json'
require 'ostruct'

def get_config
    JSON.parse( File.open('config.json').read )
end

def get_app_manifest_by_name(name)
  config = get_config
  default_app_manifest = config['app_manifest_defaults']
  mf = {
      'name' => name
  }
  mf.merge!( JSON.parse( File.open("public/apps/#{name}/manifest.json").read ) )
  mf.merge!(default_app_manifest)
end

def get_app_manifests
    mfs = []
    Dir['public/apps/*'].each do |path|
        name = File.basename(path)
        mf = get_app_manifest_by_name(name)
        mfs << mf
    end
    mfs
end 
