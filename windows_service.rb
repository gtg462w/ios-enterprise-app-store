# This runs a simple sinatra app as a service
require 'rubygems'
require 'fileutils'
require 'app'

include FileUtils

LOG_DIR = File.expand_path('./log') 
mkdir_p LOG_DIR
LOG_FILE_PATH = "#{LOG_DIR}\\ios_enterprise_services.log"

begin
  require 'win32/daemon'
  include Win32

  class DemoDaemon < Daemon
    def service_main
      MyApp.run! :host => '0.0.0.0', :port => 9091, :server => 'thin'
      while running?
        sleep 10
        File.open(LOG_FILE_PATH, "a"){ |f| f.puts "Service is running #{Time.now}" } 
      end
    end 

    def service_stop
      File.open(LOG_FILE_PATH, "a"){ |f| f.puts "***Service stopped #{Time.now}" }
      exit! 
    end
  end

  DemoDaemon.mainloop
rescue Exception => err
  File.open(LOG_FILE_PATH,'a+'){ |f| f.puts " ***Daemon failure #{Time.now} err=#{err} " }
  raise
end
