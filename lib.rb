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

def windows_authenticated?(username, domain, password)
  require 'dl/win32'

  logon32_logon_network = 3
  logon32_provider_default = 0
  bool_success = 1
  advapi32 = DL.dlopen("advapi32")
  kernel32 = DL.dlopen("kernel32")

  # Load the DLL functions
  logon_user = advapi32['LogonUser', 'ISSSIIp']
  close_handle = kernel32['CloseHandle', 'IL']

  # Authenticate user
  ptoken = "\0" * 4
  r,rs = logon_user.call(username, domain, password, logon32_logon_network, logon32_provider_default, ptoken)
  authenticated = (r == bool_success)

  # Close impersonation token
  token = ptoken.unpack('L')[0]
  close_handle.call(token)

  return authenticated
end

def user_in_access_list?(username)
  result = false
  config = get_config
  config['access_list'].each do |item|
    result |= (username.downcase == item['username'].downcase)
  end
  result
end

def is_valid_user?(username, domain, password)
  user_in_access_list?(username) && ( (RUBY_PLATFORM =~ /mswin32/) ? windows_authenticated?(username, domain, password) : true)
end